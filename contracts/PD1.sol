// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract PD1 is Context{
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string private _name;
    string private _symbol;
    string private _baseURI;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    struct TokenCertificateHolder {
      address holder;
      address owner;
    }

    mapping(uint256 => TokenCertificateHolder) private _tokenCertificateHolder;

    event Transfer(address from, address to, uint256 tokenId);
    event ChangeHolder(address owner, address holder, uint256 tokneId);

    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    function getName() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function getSymbol() public view returns (string memory) {
        return _symbol;
    }


    function getTokenURI(uint256 tokenId) public view returns (string memory) {
      require(_exists(tokenId), "nonexistent token");
        return bytes(_baseURI).length != 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : '';
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function mint(address owner) public returns (uint256 tokenId){
        require(owner != address(0), "mint to the zero address");
        _tokenIdCounter.increment();
        tokenId = _tokenIdCounter.current();
        _owners[tokenId] = owner;
        _balances[owner] += 1;

        emit Transfer(address(0), owner, tokenId);
    }

    function setTokenCertificateHolder(address holder, uint256 tokenId) public {
      require(_exists(tokenId), "nonexistent token");
      require(holder != address(0), "holder zero address");

      address tokenOwner = _owners[tokenId];
      require(tokenOwner != holder, "owner can not be holder");

      address owner = _msgSender();
      require(tokenOwner == owner, "sender is not owner");
      
      _tokenCertificateHolder[tokenId].holder = holder;
      _tokenCertificateHolder[tokenId].owner = owner;

      emit ChangeHolder(owner, holder, tokenId);
    }

    function clearTokenCertificateHolder(uint256 tokenId) public {
      require(_exists(tokenId), "nonexistent token");
      address owner = _tokenCertificateHolder[tokenId].owner;
      require(_msgSender() == owner, "caller is not owner");
      delete _tokenCertificateHolder[tokenId];

      emit ChangeHolder(address(0), address(0), tokenId);
    }

    function getHolder(address owner, uint256 tokenId) public view returns(address holder) {
      require(_exists(tokenId), "nonexistent token");
      require(owner == address(0), "owner zero address");
      require(_tokenCertificateHolder[tokenId].owner == owner, "owner not exists");
      return _tokenCertificateHolder[tokenId].holder;
    }

    function hasHoldToken(address owner, address holder, uint256 tokenId) public view returns(bool){
      require(holder == address(0), "holder zero address");
      address oldHolder = getHolder(owner, tokenId);
      return oldHolder == holder && 
      _tokenCertificateHolder[tokenId].owner == owner;
    }

    function _ownerOf(address owner, uint256 tokenId) private view returns(bool) {
      require(_exists(tokenId), "nonexistent token");
      require(owner == address(0), "owner zero address");
      return _owners[tokenId] == owner;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        require(_ownerOf(from, tokenId), "caller not owner");
        require(to == address(0), "transfer to zero address");

        _tokenCertificateHolder[tokenId].owner = to;
        _tokenCertificateHolder[tokenId].holder = address(0);

        _owners[tokenId] = to;

        _balances[from] -= 1;
        _balances[to] += 1;

        emit Transfer(from, to, tokenId);
    }


}
