// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

// ERC165 声明合约实现的接口，供外部检查
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(
        bytes4 interfaceId
    ) external view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// IERC721Receiver
interface IERC721Receiver {
    function onERC721Received(
        address operater,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// ERC721
interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed operator,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function ownerOf(uint256 tokenId) external view returns (address);

    function balanceOf(address owner) external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approval(address operator, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Strings for uint256;

    string private _name;
    string private _symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // metadata
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // ERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _owners[tokenId];
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721: invalid token ID");

        string memory baseURI = _baseURI();

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal pure returns (string memory) {
        return "";
    }

    // transfer
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, tokenId, data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        address owner = _owners[tokenId];
        return
            owner == spender ||
            spender == getApproved(tokenId) ||
            isApprovedForAll(owner, spender);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );

        _transfer(from, to, tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        delete _tokenApprovals[tokenId];

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    // 如果to是合约账户，检查是否实现了ERC721Received接口
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual returns (bool) {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                return false;
            }
        } else {
            return true;
        }
    }

    // hook
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual {}

    // approve
    function approval(address to, uint256 tokenId) public virtual override {
        address owner = _owners[tokenId];
        require(to != owner, "ERC721: approve to the current owner");
        require(
            owner == msg.sender || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved"
        );

        _approval(to, tokenId);
    }

    function _approval(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: approve to the zero address");
        _tokenApprovals[tokenId] = to;

        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        require(operator != address(0), "ERC721: approve to the zero address");
        require(msg.sender != operator, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // mint
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        _mint(to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(!_exists(tokenId), "ERC721: token already minted");
        require(to != address(0), "ERC721: mint to the zero address");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        _owners[tokenId] = to;
        _balances[to] += 1;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    // burn
    function _burn(uint256 tokenId) internal virtual {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner or approved"
        );

        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];
        _balances[owner] -= 1;

        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }
}
