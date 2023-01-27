// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { ERC20PresetFixedSupply, ERC20 } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import { IERC20Metadata } from "openzeppelin-contracts/interfaces/IERC20Metadata.sol";
import { Funnel, IFunnel, IFunnelErrors } from "../src/Funnel.sol";
import { EIP712 } from "../src/lib/EIP712.sol";
import { NativeMetaTransaction } from "../src/lib/NativeMetaTransaction.sol";
import { ERC5827TestSuite } from "./ERC5827TestSuite.sol";
import { MockSpenderReceiver } from "../src/mocks/MockSpenderReceiver.sol";
import { MockERC1271 } from "../src/mocks/MockERC1271.sol";
import { NoNameERC20 } from "../src/mocks/TestERC20TokenNoName.sol";
import { GasSnapshot } from "forge-gas-snapshot/GasSnapshot.sol";

contract FunnelTest is ERC5827TestSuite, GasSnapshot {
    event TransferReceived(address operator, address from, uint256 value);
    event RenewableApprovalReceived(address owner, uint256 value, uint256 recoveryRate);

    ERC20 token;
    Funnel funnel;

    MockERC1271 contractWallet;

    MockSpenderReceiver spender;

    // keccak256(
    //     "PermitRenewable(address owner,address spender,uint256 value,uint256 recoveryRate,uint256 nonce,uint256 deadline)"
    // )
    bytes32 internal PERMIT_RENEWABLE_TYPEHASH = 0x4c7980a0d4b6c380a9911208fee8e0a4cec3c9be70b18695b1089dde159ff934;

    // keccak256(
    //     "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    // )
    bytes32 constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    // keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)")
    bytes32 constant META_TRANSACTION_TYPEHASH = 0x23d10def3caacba2e4042e0c75d44a42d2558aabcf5ce951d0642a8032e1e653;

    function setUp() public override {
        uint256 privateKey = 0xBEEF;
        user1 = vm.addr(privateKey);
        user2 = address(0xCAFE);
        user3 = address(0xDEAD);

        token = new ERC20PresetFixedSupply("Existing USDC token", "USDC", type(uint256).max, user1);

        funnel = new Funnel();
        funnel.initialize(address(token));
        renewableToken = funnel;

        spender = new MockSpenderReceiver();

        vm.prank(user1);
        contractWallet = new MockERC1271(); // contract wallet owned by user1

        vm.prank(user1);
        // approves proxy contract to handle allowance
        token.approve(address(funnel), type(uint256).max);
    }

    function testZeroAddressInitialise() public {
        funnel = new Funnel();
        vm.expectRevert(abi.encodeWithSelector(IFunnelErrors.InvalidAddress.selector, address(0)));
        funnel.initialize(address(0));
    }

    function testBaseToken() public {
        assertEq(funnel.baseToken(), address(token));
    }

    function testRecoveryRateExceeded2() public {
        vm.prank(user1);
        vm.expectRevert(IFunnel.RecoveryRateExceeded.selector);
        funnel.approveRenewable(user2, 100, 101);
    }

    function testBaseTokenAllowance() public {
        vm.startPrank(user1);
        token.approve(address(funnel), 100);
        assertEq(token.allowance(user1, address(funnel)), 100);

        funnel.approveRenewable(address(spender), type(uint256).max, 1);
        assertEq(funnel.allowance(user1, address(spender)), 100); // reflects base token allowance
    }

    function testTransferFromWithSnapshot() public {
        vm.prank(user1);
        funnel.approve(address(this), type(uint256).max);
        snapStart("transferFrom");
        funnel.transferFrom(user1, user2, 13370);
        snapEnd();
    }

    function testInfiniteApproveTransferFrom() public {
        vm.prank(user1);
        funnel.approve(address(this), type(uint256).max);

        assertTrue(funnel.transferFrom(user1, user2, 13370));

        assertEq(funnel.allowance(user1, address(this)), type(uint256).max);

        assertEq(funnel.balanceOf(user1), type(uint256).max - 13370);
        assertEq(funnel.balanceOf(user2), 13370);
    }

    function testTransferFromAndCall() public {
        vm.prank(user1);

        funnel.approveRenewable(user2, 1337, 1);

        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit TransferReceived(user2, user1, 10);
        assertTrue(funnel.transferFromAndCall(user1, address(spender), 10, ""));
    }

    function testTransferFromAndCallWithGasSnapshot() public {
        vm.prank(user1);

        snapStart("approveRenewable");
        funnel.approveRenewable(user2, 1337, 1);
        snapEnd();

        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit TransferReceived(user2, user1, 10);

        snapStart("transferFromAndCall");
        assertTrue(funnel.transferFromAndCall(user1, address(spender), 10, ""));
        snapEnd();
    }

    function testInsufficientBaseAllowance() public {
        vm.prank(user1);
        token.approve(address(funnel), 0);

        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);

        assertEq(funnel.allowance(user1, address(spender)), 0);

        vm.prank(user2);
        vm.expectRevert("ERC20: insufficient allowance");
        funnel.transferFromAndCall(user1, address(spender), 10, "");
    }

    function testOverflow() public {
        vm.prank(user1);
        funnel.approveRenewable(address(user2), type(uint256).max - type(uint192).max + 1, type(uint192).max);
        skip(1);
        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit Transfer(user1, user2, type(uint256).max - type(uint192).max + 1);
        assertTrue(funnel.transferFrom(user1, user3, type(uint256).max - type(uint192).max + 1));
        assertEq(token.balanceOf(user3), type(uint256).max - type(uint192).max + 1);
    }

    function testOverflow2() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, type(uint256).max - type(uint64).max + 1, type(uint64).max);
        skip(1);
        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit Transfer(user1, user2, type(uint256).max - type(uint64).max + 1);
        assertTrue(funnel.transferFrom(user1, user3, type(uint256).max - type(uint64).max + 1));
        assertEq(token.balanceOf(user3), type(uint256).max - type(uint64).max + 1);
    }

    function testOverflow3() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, type(uint256).max, type(uint64).max);
        skip(1);
        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit Transfer(user1, user2, type(uint256).max);
        assertTrue(funnel.transferFrom(user1, user3, type(uint256).max));
        assertEq(token.balanceOf(user3), type(uint256).max);
    }

    function testOverflow4() public {
        vm.prank(user1);
        funnel.approveRenewable(
            user2,
            0xef0000000000000000000000000000000000000000000000000000000000a5cf,
            0xebffffff000000000000000000000000000000000000000001
        );

        skip(5415);

        uint256 rAllowance = funnel.allowance(user1, user2);
        assertEq(rAllowance, 0xef0000000000000000000000000000000000000000000000000000000000a5cf);
    }

    function testRecoveryRateCasting() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, type(uint256).max, type(uint256).max);

        (uint256 initial, uint256 recoveryRate) = funnel.renewableAllowance(user1, user2);

        assertEq(initial, type(uint256).max);
        assertEq(recoveryRate, type(uint192).max);
    }

    function testTransferFromAndCallRevertNonContract() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);
        vm.prank(user2);
        vm.expectRevert(IFunnelErrors.NotContractError.selector);
        funnel.transferFromAndCall(user1, address(user3), 1337, "");
    }

    function testTransferFromAndCallRevertNonReceiver() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);

        vm.prank(user2);
        // Attempting to transfer to a non IERC1363Receiver
        vm.expectRevert(IFunnel.NotIERC1363Receiver.selector);
        funnel.transferFromAndCall(user1, address(token), 1337, "");
    }

    function testApproveRenewableAndCall() public {
        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit RenewableApprovalReceived(user1, 1337, 1);
        assertTrue(funnel.approveRenewableAndCall(address(spender), 1337, 1, ""));
    }

    function testApproveRenewableAndCallWithGasSnapshot() public {
        vm.prank(user1);
        snapStart("approveRenewableAndCall");
        funnel.approveRenewableAndCall(address(spender), 1337, 1, "");
        snapEnd();
    }

    function testApproveRenewableAndCallRevertNonContract() public {
        vm.expectRevert(IFunnelErrors.NotContractError.selector);
        funnel.approveRenewableAndCall(address(user3), 1337, 1, "");
    }

    function testApproveRenewableAndCallRevertNonReceiver() public {
        // attempting to approve a non IERC5827Spender
        vm.expectRevert(IFunnel.NotIERC5827Spender.selector);
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
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, user2, 1e18, 0, block.timestamp))
                )
            )
        );

        snapStart("permit");
        funnel.permit(owner, user2, 1e18, block.timestamp, v, r, s);
        snapEnd();

        assertEq(funnel.allowance(owner, user2), 1e18);
        assertEq(funnel.nonces(owner), 1);
    }

    function testRevertPermitBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, user2, 1e18, 1, block.timestamp))
                )
            )
        );
        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.permit(owner, user2, 1e18, block.timestamp, v, r, s);
    }

    function testRevertPermitBadDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, user2, 1e18, 0, block.timestamp))
                )
            )
        );
        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.permit(owner, user2, 1e18, block.timestamp + 1, v, r, s);
    }

    function testRevertPermitPastDeadline() public {
        uint256 oldTimestamp = block.timestamp;
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, oldTimestamp))
                )
            )
        );

        vm.warp(block.timestamp + 1);
        vm.expectRevert(IFunnelErrors.PermitExpired.selector);
        funnel.permit(owner, address(0xCAFE), 1e18, oldTimestamp, v, r, s);
    }

    function testRevertPermitReplay() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        uint256 timestamp = block.timestamp;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, user2, 1e18, 0, timestamp))
                )
            )
        );

        funnel.permit(owner, user2, 1e18, timestamp, v, r, s);
        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.permit(owner, user2, 1e18, timestamp, v, r, s);
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
                    keccak256(abi.encode(PERMIT_RENEWABLE_TYPEHASH, owner, user2, 1e18, 1, 0, block.timestamp))
                )
            )
        );

        funnel.permitRenewable(owner, user2, 1e18, 1, block.timestamp, v, r, s);

        assertEq(funnel.allowance(owner, user2), 1e18);
        assertEq(funnel.nonces(owner), 1);
    }

    function testPermitRenewableContractWallet() public {
        uint256 privateKey = 0xBEEF; // user1

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            address(contractWallet),
                            user2,
                            1e18,
                            1,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        funnel.permitRenewable(address(contractWallet), user2, 1e18, 1, block.timestamp, v, r, s);
        (uint256 maxAmount, uint256 recoveryRate) = funnel.renewableAllowance(address(contractWallet), user2);
        assertEq(maxAmount, 1e18);
        assertEq(recoveryRate, 1);
        assertEq(funnel.nonces(address(contractWallet)), 1);
    }

    function testRevertPermitRenewableContractWalletBadSigner() public {
        uint256 privateKey = 0xBADBEEF; // invalid signer

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_RENEWABLE_TYPEHASH,
                            address(contractWallet),
                            user2,
                            1e18,
                            1,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );
        vm.expectRevert(EIP712.IERC1271InvalidSignature.selector);
        funnel.permitRenewable(address(contractWallet), user2, 1e18, 1, block.timestamp, v, r, s);
    }

    function testRevertPermitRenewableBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_RENEWABLE_TYPEHASH, owner, user2, 1e18, 1, 1, block.timestamp))
                )
            )
        );

        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.permitRenewable(owner, user2, 1e18, 1, block.timestamp, v, r, s);
    }

    function testRevertPermitRenewableBadDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_RENEWABLE_TYPEHASH, owner, user2, 1e18, 1, 0, block.timestamp))
                )
            )
        );

        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.permitRenewable(owner, user2, 1e18, 1, block.timestamp + 1, v, r, s);
    }

    function testRevertPermitRenewablePastDeadline() public {
        uint256 oldTimestamp = block.timestamp;
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_RENEWABLE_TYPEHASH, owner, user2, 1e18, 1, 0, oldTimestamp))
                )
            )
        );

        vm.warp(oldTimestamp + 1);
        vm.expectRevert(IFunnelErrors.PermitExpired.selector);
        funnel.permitRenewable(owner, user2, 1e18, 1, oldTimestamp, v, r, s);
    }

    function testRevertPermitRenewableReplay() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        uint256 timestamp = block.timestamp;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_RENEWABLE_TYPEHASH, owner, user2, 1e18, 1, 0, timestamp))
                )
            )
        );

        funnel.permitRenewable(owner, user2, 1e18, 1, timestamp, v, r, s);
        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.permitRenewable(owner, user2, 1e18, 1, timestamp, v, r, s);
    }

    function testExecuteMetaTransactionApproveRenewable() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        bytes memory functionSignature = abi.encodeWithSignature(
            "approveRenewable(address,uint256,uint256)",
            user2,
            1e18,
            1
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, 0, owner, keccak256(functionSignature)))
                )
            )
        );
        snapStart("executeMetaTransactionApproveRenewable");

        funnel.executeMetaTransaction(owner, functionSignature, r, s, v);
        snapEnd();

        assertEq(funnel.allowance(owner, user2), 1e18);
        assertEq(funnel.nonces(owner), 1);
    }

    function testExecuteMetaTransactionTransfer() public {
        uint256 privateKey = 0xBEEF;

        bytes memory functionSignature = abi.encodeWithSignature("transfer(address,uint256)", user2, 1337);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, 0, user1, keccak256(functionSignature)))
                )
            )
        );

        snapStart("executeMetaTransactionTransfer");
        funnel.executeMetaTransaction(user1, functionSignature, r, s, v);
        snapEnd();

        assertEq(funnel.balanceOf(user2), 1337);
        assertEq(funnel.nonces(user1), 1);
    }

    function testRevertExecuteMetaTransactionCallFailed() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);
        bytes memory functionSignature = abi.encodeWithSignature(
            "approveRenewableBad(address,uint256,uint256)",
            user2,
            1e18,
            1
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, 0, owner, keccak256(functionSignature)))
                )
            )
        );

        vm.expectRevert(NativeMetaTransaction.FunctionCallError.selector);
        funnel.executeMetaTransaction(owner, functionSignature, r, s, v);
    }

    function testRevertExecuteMetaTransactionInvalidSigner() public {
        uint256 privateKey = 0xBEEF;

        bytes memory functionSignature = abi.encodeWithSignature(
            "approveRenewable(address,uint256,uint256)",
            user2,
            1e18,
            1
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, 0, address(0), keccak256(functionSignature)))
                )
            )
        );

        vm.expectRevert(NativeMetaTransaction.InvalidSigner.selector);
        funnel.executeMetaTransaction(address(0), functionSignature, r, s, v);
    }

    function testRevertExecuteMetaTransactionBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        bytes memory functionSignature = abi.encodeWithSignature(
            "approveRenewable(address,uint256,uint256)",
            user2,
            1e18,
            1
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, 1, owner, keccak256(functionSignature)))
                )
            )
        );
        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.executeMetaTransaction(owner, functionSignature, r, s, v);
    }

    function testRevertExecuteMetaTransactionReplayProtection() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        bytes memory functionSignature = abi.encodeWithSignature(
            "approveRenewable(address,uint256,uint256)",
            user2,
            1e18,
            1
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    funnel.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, 0, owner, keccak256(functionSignature)))
                )
            )
        );

        funnel.executeMetaTransaction(owner, functionSignature, r, s, v);
        assertEq(funnel.allowance(owner, user2), 1e18);
        assertEq(funnel.nonces(owner), 1);
        vm.expectRevert(EIP712.InvalidSignature.selector);
        funnel.executeMetaTransaction(owner, functionSignature, r, s, v);
    }

    function testSupportsInterfaceProxy() public view {
        assert(funnel.supportsInterface(0xc55dae63));
    }

    function testSupportsInterfacePayable() public view {
        assert(funnel.supportsInterface(0x3717806a));
    }

    function testOverriddenName() public {
        assertEq(IERC20Metadata(address(funnel)).name(), string.concat(token.name(), " (funnel)"));
    }

    function testOverriddenNameWithNoName() public {
        // instantiate token with noname
        NoNameERC20 tokenNoName = new NoNameERC20("NONAME");

        funnel = new Funnel();
        funnel.initialize(address(tokenNoName));

        assertEq(
            IERC20Metadata(address(funnel)).name(),
            string.concat(toString(abi.encodePacked(address(tokenNoName))), " (funnel)")
        );
    }

    function testFallbackToBaseToken() public {
        assertEq(IERC20Metadata(address(funnel)).symbol(), token.symbol());
        assertEq(IERC20Metadata(address(funnel)).decimals(), token.decimals());
        assertEq(IERC20Metadata(address(funnel)).totalSupply(), token.totalSupply());
    }

    // helper function
    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
