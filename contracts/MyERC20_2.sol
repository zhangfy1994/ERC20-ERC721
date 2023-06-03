// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//MyERC20_2
contract MyERC20_2 is Ownable, ERC20 {
    bool public limited;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapV2Pair;
    mapping(address => bool) public blacklists;

    constructor(uint256 _totalSupply) ERC20("myERC20", "MyERC20") {
        _mint(msg.sender, _totalSupply);
    }

    function setRule(
        bool _limited,
        uint256 _maxHoldingAmount,
        uint256 _minHoldingAmount,
        address _uniswapV2Pair
    ) external onlyOwner {
        limited = _limited;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
        uniswapV2Pair = _uniswapV2Pair;
    }

    function blacklist(
        address account,
        bool _isBlacklisting
    ) external onlyOwner {
        blacklists[account] = _isBlacklisting;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        require(!blacklists[from] && !blacklists[to], "blacklisted");

        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading not started");
            return;
        }

        if (limited && uniswapV2Pair == from) {
            require(
                super.balanceOf(to) + amount <= maxHoldingAmount &&
                    super.balanceOf(to) + amount >= minHoldingAmount,
                "Forbid"
            );
        }
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
