// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {ERC20Swapper} from "./interfaces/ERC20Swapper.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EigerSwap is ERC20Swapper, Ownable {    
    address public immutable weth;
    IUniswapV2Factory public factory;

    error WethNotDefined();
    error NoFactoryDefined();
    error NoPairFound();

    constructor(
        address initialOwner,
        IUniswapV2Factory initialFactory,
        address _weth
    ) Ownable(initialOwner) {
        if (_weth == address(0)) {
            revert WethNotDefined();
        }
        factory = initialFactory;
        weth = _weth;
    }

    function setFactory(IUniswapV2Factory newFactory) external onlyOwner {
        factory = newFactory;
    }

    function swapEtherToToken(
        address token,
        uint minAmount
    ) public payable returns (uint) {
        if (address(factory) == address(0)) {
            // we can block swap if factory was not defined
            revert NoFactoryDefined();
        }

        address pair = factory.getPair(weth, token);
        if (pair == address(0)) {
            // some pair didn't exist check it before swap
            revert NoPairFound();
        }

        return 0;
    }
}
