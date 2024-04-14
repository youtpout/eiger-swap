// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {ERC20Swapper} from "./interfaces/ERC20Swapper.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {UniswapV2Library} from "./libraries/UniswapV2Library.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TransferHelper} from "./libraries/TransferHelper.sol";
import {IWETH} from "./interfaces/IWETH.sol";

contract EigerSwap is ERC20Swapper, Ownable {
    address immutable weth;
    address public factory;

    error WethNotDefined();
    error NoFactoryDefined();
    error NoPairFound();
    error InsufficientOutputAmount(uint256 amount);
    error InsufficientOutputAmountAfterSwap(uint256 amount);

    constructor(
        address initialOwner,
        address initialFactory,
        address _weth
    ) Ownable(initialOwner) {
        if (_weth == address(0)) {
            revert WethNotDefined();
        }
        factory = initialFactory;
        weth = _weth;
    }

    /// @dev Define the factory contracts used to swap tokens, the factory need to be compatible with IUniswapV2Factory
    /// can be zero if you want to stop to use swap
    /// @param newFactory address
    function setFactory(address newFactory) external onlyOwner {
        factory = newFactory;
    }

    /// @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
    /// @param token The address of ERC-20 token to swap
    /// @param minAmount The minimum amount of tokens transferred to msg.sender
    /// @return The actual amount of transferred tokens
    function swapEtherToToken(
        address token,
        uint minAmount
    ) public payable returns (uint) {
        if (address(factory) == address(0)) {
            // we block swap if factory was not defined
            revert NoFactoryDefined();
        }

        address pair = IUniswapV2Factory(factory).getPair(weth, token);
        if (pair == address(0)) {
            // some pair didn't exist check it before swap
            revert NoPairFound();
        }

        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;

        // use uniswap v2 library (can be optimized if we call directly getAmountOut with reserves)
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(
            factory,
            msg.value,
            path
        );

        uint256 expectedAmountOut = amounts[amounts.length - 1];

        if (expectedAmountOut < minAmount) {
            revert InsufficientOutputAmount(expectedAmountOut);
        }

        IERC20 tokenOut = IERC20(token);
        // we check balance before and after to check if minAmount is respected in case of token has fees
        uint256 balanceBefore = tokenOut.balanceOf(msg.sender);

        // we transfer weth to the pair to execute swap
        IWETH(weth).deposit{value: msg.value}();
        TransferHelper.safeTransfer(IERC20(weth), pair, msg.value);

        // define if it's amount0 or amount1 who out based on token address
        (uint amount0Out, uint amount1Out) = weth < token
            ? (uint(0), expectedAmountOut)
            : (expectedAmountOut, uint(0));

        // call swap with expected out, we put sender as direct receiver, and bytes(0) because is not a flash swap
        /* IUniswapV2Pair(pair).swap(
            amount0Out,
            amount1Out,
            msg.sender,
            new bytes(0)
        );*/

        bytes4 swapSignature = IUniswapV2Pair.swap.selector;
        // assembly just for the style, saw is a plus for the job
        assembly {
            // 0x40 is the first slot freely available for memory storage
            let ptr := mload(0x40)
            // first parameter is the method signature, use 4bytes of storage
            mstore(ptr, swapSignature)
            // other parameters will use 0x20 or 32 bytes of storage (0x20 = 32)
            mstore(add(ptr, 0x4), amount0Out)
            mstore(add(ptr, 0x24), amount1Out)
            // caller() is msg.sender()
            mstore(add(ptr, 0x44), caller())
            // calldata store position, 0x80 position of where length of "bytes data" is stored from first arg (excluding func signature)
            mstore(add(ptr, 0x64), 0x80)
            // call external function
            // first parameter the gas limit, gas() is the actual gas left
            // second is the contract address
            // third is the wei to send (0 in our case)
            // fourth is the memory pointer position read for parameter
            // fifth is the size of memory parameters (0xa4 for 4 bytes signatures + 0x60 for 3 parameters in + 0x40 for calldata)
            // sixth is the memory pointer address where store function return value (the function return nothing so we will use 0)
            // seventh is the size of the return value (the function return nothing so we will use 0)
            // result is 0 if call failed or 1 if succeed
            let result := call(gas(), pair, 0, ptr, 0xa4, 0, 0)

            // check if call was succesfull, else revert
            if iszero(result) {
                // the error was return has data, we just need to throw it
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        uint256 balanceAfter = tokenOut.balanceOf(msg.sender);

        uint256 amountReceived = balanceAfter - balanceBefore;
        if (amountReceived < minAmount) {
            revert InsufficientOutputAmountAfterSwap(amountReceived);
        }

        // return the amount received by the user, cannot reflect reality in the case of tokens with reflection
        return amountReceived;
    }
}
