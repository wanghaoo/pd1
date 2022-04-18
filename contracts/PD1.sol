// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";

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
      bool isValid;
    }

    mapping(uint256 => TokenCertificateHolder) private _tokenCertificateHolder;

    event Transfer(address from, address to, uint256 tokenId);
    event ChangeHolder(address owner, address holder, uint256 tokneId);

    modifier existsToken(uint256 tokenId) {
      require(_exists(tokenId), "nonexistent token");
      _;
    } 

    modifier notZeroAddress(address addr) {
      require(addr != address(0), "zero address");
      _;
    }

    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    function getName() public view returns (string memory) {
        return _name;
    }

    function getSymbol() public view returns (string memory) {
        return _symbol;
    }


    function getTokenURI(uint256 tokenId) public view existsToken(tokenId) returns (string memory) {
      return bytes(_baseURI).length != 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : '';
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function mint(address owner) public notZeroAddress(owner) returns (uint256 tokenId){
        _tokenIdCounter.increment();
        tokenId = _tokenIdCounter.current();
        _owners[tokenId] = owner;
        _balances[owner] += 1;

        emit Transfer(address(0), owner, tokenId);
    }

    function setTokenCertificateHolder(address holder, uint256 tokenId) public  notZeroAddress(holder) existsToken(tokenId){
      address tokenOwner = _owners[tokenId];
      require(tokenOwner != holder, "owner can not be holder");

      address owner = _msgSender();
      require(tokenOwner == owner, "sender is not owner");
      
      _tokenCertificateHolder[tokenId].holder = holder;
      _tokenCertificateHolder[tokenId].owner = owner;
      _tokenCertificateHolder[tokenId].isValid = true;

      emit ChangeHolder(owner, holder, tokenId);
    }

    function clearTokenCertificateHolder(uint256 tokenId) public existsToken(tokenId) {
      bool isValid = _tokenCertificateHolder[tokenId].isValid;
      require(isValid, "token not exists holder");
      address owner = _tokenCertificateHolder[tokenId].owner;
      require(_msgSender() == owner, "caller is not owner");
      _tokenCertificateHolder[tokenId].owner = address(0);
      _tokenCertificateHolder[tokenId].holder = address(0);
      _tokenCertificateHolder[tokenId].isValid = false;

      emit ChangeHolder(address(0), address(0), tokenId);
    }

    function getHolder(address owner, uint256 tokenId) public view  notZeroAddress(owner) existsToken(tokenId) returns(address holder) {
      bool isValid = _tokenCertificateHolder[tokenId].isValid;
      if (isValid && _tokenCertificateHolder[tokenId].owner == owner) {
        return _tokenCertificateHolder[tokenId].holder;
      } else {
        return address(0);
      }
    }

    function hasHoldToken(address owner, address holder, uint256 tokenId) public view  notZeroAddress(owner) notZeroAddress(holder) existsToken(tokenId) returns(bool){
      bool isValid = _tokenCertificateHolder[tokenId].isValid;
      if (isValid) {
        return _tokenCertificateHolder[tokenId].holder == holder && 
            _tokenCertificateHolder[tokenId].owner == owner;
      }
      return false;
    }

    function _ownerOf(address owner, uint256 tokenId) private view notZeroAddress(owner) existsToken(tokenId) returns(bool) {
      return _owners[tokenId] == owner;
    }

    function transfer(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(_ownerOf(from, tokenId), "caller not owner");
        require(to != address(0), "transfer to zero address");

        _tokenCertificateHolder[tokenId].owner = to;
        _tokenCertificateHolder[tokenId].holder = address(0);
        _tokenCertificateHolder[tokenId].isValid = false;

        _owners[tokenId] = to;

        _balances[from] -= 1;
        _balances[to] += 1;

        emit Transfer(from, to, tokenId);
    }

    function balanceOf(address owner) public view  notZeroAddress(owner) returns (uint256) {
        return _balances[owner];
    }

}
