// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import {IERC20Metadata} from "openzeppelin-contracts/interfaces/IERC20Metadata.sol";
import "../src/Funnel.sol";
import "./ERC5827TestSuite.sol";
import "../src/mocks/MockSpenderReceiver.sol";

contract FunnelTest is ERC5827TestSuite {
    event TransferReceived(address operator, address from, uint256 value);
    event RenewableApprovalReceived(
        address owner,
        uint256 value,
        uint256 recoveryRate
    );

    ERC20 token;
    Funnel funnel;

    MockSpenderReceiver spender;

    // keccak256(
    //     "PermitRenewable(address owner,address spender,uint256 value,uint256 recoveryRate,uint256 nonce,uint256 deadline)"
    // )
    bytes32 internal PERMIT_RENEWABLE_TYPEHASH =
        0x4c7980a0d4b6c380a9911208fee8e0a4cec3c9be70b18695b1089dde159ff934;

    // keccak256(
    //     "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    // )
    bytes32 constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    function setUp() public override {
        user1 = address(0x1111111111111111111111111111111111111111);
        user2 = address(0x2222222222222222222222222222222222222222);
        user3 = address(0x3333333333333333333333333333333333333333);

        token = new ERC20PresetFixedSupply(
            "Existing USDC token",
            "USDC",
            13370,
            user1
        );

        funnel = new Funnel();
        funnel.initialize(token);
        renewableToken = funnel;

        spender = new MockSpenderReceiver();

        vm.prank(user1);
        // approves proxy contract to handle allowance
        token.approve(address(funnel), type(uint256).max);
    }

    function testBaseToken() public {
        assertEq(funnel.baseToken(), address(token));
    }

    function testRecoveryRateExceeded2() public {
        vm.prank(user1);
        vm.expectRevert(IFunnel.RecoveryRateExceeded.selector);
        funnel.approveRenewable(user2, 100, 101);
    }

    function testInfiniteApproveTransferFrom() public {
        vm.prank(user1);
        funnel.approve(address(this), type(uint256).max);

        assertTrue(funnel.transferFrom(user1, user2, 13370));

        assertEq(funnel.allowance(user1, address(this)), type(uint256).max);

        assertEq(funnel.balanceOf(user1), 0);
        assertEq(funnel.balanceOf(user2), 13370);
    }

    function testTransferFromAndCall() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);

        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit TransferReceived(user2, user1, 10);
        assertEq(
            funnel.transferFromAndCall(user1, address(spender), 10, ""),
            true
        );
    }

    function testTransferFromAndCallRevertNonContract() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);
        vm.prank(user2);
        vm.expectRevert("IERC5827Payable: transfer to non contract address");
        funnel.transferFromAndCall(user1, address(user3), 1337, "");
    }

    function testTransferFromAndCallRevertNonReceiver() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);

        vm.prank(user2);
        vm.expectRevert(
            "IERC5827Payable: transfer to non IERC1363Receiver implementer"
        );
        funnel.transferFromAndCall(user1, address(token), 1337, "");
    }

    function testApproveRenewableAndCall() public {
        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit RenewableApprovalReceived(user1, 1337, 1);
        assertTrue(
            funnel.approveRenewableAndCall(address(spender), 1337, 1, "")
        );
    }

    function testApproveRenewableAndCallRevertNonContract() public {
        vm.expectRevert("IERC5827Payable: approve a non contract address");
        funnel.approveRenewableAndCall(address(user3), 1337, 1, "");
    }

    function testApproveRenewableAndCallRevertNonReceiver() public {
        vm.expectRevert(
            "IERC5827Payable: approve a non IERC5827Spender implementer"
        );
        funnel.approveRenewableAndCall(address(token), 1337, 1, "");
    }

    function testPermit() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);

        assertEq(funnel.allowance(owner, address(0xCAFE)), 1e18);
        assertEq(funnel.nonces(owner), 1);
    }

    function testFailPermitBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            1,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }

    function testFailPermitBadDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permit(
            owner,
            address(0xCAFE),
            1e18,
            block.timestamp + 1,
            v,
            r,
            s
        );
    }

    function testFailPermitPastDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            0,
                            block.timestamp - 1
                        )
                    )
                )
            )
        );

        funnel.permit(
            owner,
            address(0xCAFE),
            1e18,
            block.timestamp - 1,
            v,
            r,
            s
        );
    }

    function testFailPermitReplay() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
        funnel.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }

    function testFailPermitRenewableBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            1,
                            1,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permitRenewable(
            owner,
            address(0xCAFE),
            1e18,
            1,
            block.timestamp,
            v,
            r,
            s
        );
    }

    function testFailPermitRenewableBadDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            1,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permitRenewable(
            owner,
            address(0xCAFE),
            1e18,
            1,
            block.timestamp + 1,
            v,
            r,
            s
        );
    }

    function testFailPermitRenewablePastDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            1,
                            0,
                            block.timestamp - 1
                        )
                    )
                )
            )
        );

        funnel.permitRenewable(
            owner,
            address(0xCAFE),
            1e18,
            1,
            block.timestamp - 1,
            v,
            r,
            s
        );
    }

    function testPermitRenewable() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            1,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permitRenewable(
            owner,
            address(0xCAFE),
            1e18,
            1,
            block.timestamp,
            v,
            r,
            s
        );

        assertEq(funnel.allowance(owner, address(0xCAFE)), 1e18);
        assertEq(funnel.nonces(owner), 1);
    }

    function testFailPermitRenewableReplay() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            owner,
                            address(0xCAFE),
                            1e18,
                            1,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permitRenewable(
            owner,
            address(0xCAFE),
            1e18,
            1,
            block.timestamp,
            v,
            r,
            s
        );
        funnel.permitRenewable(
            owner,
            address(0xCAFE),
            1e18,
            1,
            block.timestamp,
            v,
            r,
            s
        );
    }

    function testSupportsInterfaceProxy() public view {
        assert(funnel.supportsInterface(0xc55dae63));
    }

    function testSupportsInterfacePayable() public view {
        assert(funnel.supportsInterface(0x3717806a));
    }

    function testOverriddenName() public {
        assertEq(
            IERC20Metadata(address(funnel)).name(),
            string.concat(token.name(), " (funnel)")
        );
    }

    function testFallbackToBaseToken() public {
        assertEq(IERC20Metadata(address(funnel)).symbol(), token.symbol());
        assertEq(IERC20Metadata(address(funnel)).decimals(), token.decimals());
        assertEq(IERC20Metadata(address(funnel)).totalSupply(), token.totalSupply());
    }
}
