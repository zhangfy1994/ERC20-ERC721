// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 权限合约
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address previousOwner = _owner;
        _owner = newOwner;

        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function getOwner() internal view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "newOwner cannot be the zero address");
        _transferOwnership(newOwner);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not owner");
        _;
    }
}

// IERC20
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 amout) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amout
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// ERC20Metadata
interface ERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// ERC20
contract ERC20 is Ownable, IERC20, ERC20Metadata {
    string private _name;
    string private _symbol;

    uint256 private _totalSupply;

    mapping(address => uint256) _balanceOf;
    mapping(address => mapping(address => uint256)) _allowance;

    // constructor
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // metadata
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address owner
    ) public view virtual override returns (uint256) {
        return _balanceOf[owner];
    }

    function allowance(
        address owner,
        address spender
    ) external view virtual override returns (uint256) {
        return _allowance[owner][spender];
    }

    // transfer
    function transfer(
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        _beforeTokenTransfer(from, to, amount);

        require(from != address(0), "transfer from cannot be the zero address");
        require(to != address(0), "transfer to cannot be the zero address");

        uint256 ownerBalance = _balanceOf[from];
        require(
            ownerBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balanceOf[from] = ownerBalance - amount;
        _balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // approve
    function approve(
        address spender,
        uint256 amount
    ) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            owner != address(0),
            "approve owner cannot be the zero address"
        );
        require(
            spender != address(0),
            "approve spender cannot be the zero address"
        );

        _allowance[owner][spender] = amount;
        emit Approve(owner, spender, amount);
    }

    // transferFrom
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        // 转账要小于等于授权额度
        uint256 allowanceValue = _allowance[from][msg.sender];
        require(allowanceValue >= amount, "ERC20: insufficient allowance");

        _transfer(from, to, amount);
        _approve(from, msg.sender, allowanceValue - amount);

        return true;
    }

    // mint
    function _mint(address account, uint256 amount) internal virtual {
        require(
            account != address(0),
            "mint to address cannot be the zero address"
        );
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // burn
    function _burn(address account, uint256 amount) internal virtual {
        require(
            account != address(0),
            "burn to address cannot be the zero address"
        );

        uint256 balance = _balanceOf[account];
        require(balance >= amount, "ERC20: burn amount exceeds balance");

        _beforeTokenTransfer(account, address(0), amount);

        _totalSupply -= amount;
        _balanceOf[account] = balance - amount;
        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
}

//MyERC20
contract MyERC20 is ERC20 {
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
            require(
                from == getOwner() || to == getOwner(),
                "trading not started"
            );
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
