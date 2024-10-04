// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Taxation is ERC20, Ownable {
    IUniswapV2Router02 private uniswapV2Router;

    uint8 private s_initialSellTax = 2;
    uint8 private s_finalSellTax = 0;
    uint256 private s_marketCap = 0;

    address private immutable i_uniswapPair;

    uint256 private s_lastTimestamp;
    uint256 private immutable i_keeperInterval;

    mapping(address => bool) private s_marketPair;
    mapping(address => bool) private s_isExile;

    constructor(
        uint256 _initalSupply,
        address _uniswapV2Router02
    ) ERC20("Taxation", "TAXON") Ownable(msg.sender) {
        _mint(_msgSender(), _initalSupply);
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router02);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        i_uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        s_marketPair[address(i_uniswapPair)] = true;

        s_isExile[owner()] = true;
        s_isExile[address(this)] = true;
        s_isExile[address(i_uniswapPair)] = true;
    }

    // function transferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _amount
    // ) public override returns (bool) {
    //     require(_from != address(0), "ERC20: transfer from the zero address");
    //     require(_to != address(0), "ERC20: transfer to the zero address");
    //     require(_amount > 0, "Transfer amount must be greater than zero");

    //     uint256 taxAmount = 0;
    //     uint256 marketCap = _calculateMarketCap();

    //     if (_from != owner() && _to != owner()) {
    //         if (marketCap < 1000000) {
    //             taxAmount = _amount * s_initialSellTax;
    //         }
    //     }
    // }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function _calculateMarketCap() internal view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(i_uniswapPair);
        (uint112 reserveA, uint112 reserveB, ) = pair.getReserves();

        uint256 tokenSupply = IERC20(address(this)).totalSupply();

        uint256 priceOfToken = uint256(reserveB) / uint256(reserveA);

        uint256 marketCap = priceOfToken * tokenSupply;
        return marketCap;
    }

    // /* check marketcap every day */
    // function checkUpkeep(
    //     bytes memory /* checkData */
    // )
    //     public
    //     view
    //     override
    //     returns (bool upkeepNeeded, bytes memory /* performData */)
    // {
    //     upkeepNeeded = ((block.timestamp - s_lastTimestamp) > 1 days);
    //     return (upkeepNeeded, "0x0");
    // }

    // /* set market cap every day */
    // function performUpkeep(bytes calldata /* performData */) external override {
    //     (bool upkeepNeeded, ) = checkUpkeep("");

    //     require(upkeepNeeded, "upkeep not needed");
    // }
}
