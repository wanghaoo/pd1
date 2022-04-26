// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";


contract PD1Certificate is Context {

  using Address for address;

  struct CertificateHolder {
    address holder;
    address tokenOwner;
  }

  mapping(address => mapping(uint256 => CertificateHolder)) _certificateHolder;

  event ChangeHolder(address contractAddress, address holderAddress, uint256 tokenId);

  modifier Owner721Token(address contractAddress) {
    require(contractAddress != address(0), "zero contract address");
    require(contractAddress.isContract(), "invalid contract address");
    _;
  }

  function getTokenOwner(address payable contractAddress, uint256 tokenId) public view returns(address) {
    return IERC721(contractAddress).ownerOf(tokenId);
  }

  function issuingOfCertificates(address contractAddress, address holderAddress, uint256 tokenId) 
  public Owner721Token(contractAddress) {
    require(holderAddress != address(0), "zero holder address");
    require(holderAddress != _msgSender(), "owner not be holder");
    _certificateHolder[contractAddress][tokenId].holder = holderAddress;
    _certificateHolder[contractAddress][tokenId].tokenOwner = _msgSender();
    emit ChangeHolder(contractAddress, holderAddress, tokenId);
  }

  function clearCertificatesHolder(address contractAddress, uint256 tokenId) 
  public Owner721Token(contractAddress) {
    require(ownerOf(contractAddress, tokenId) == _msgSender(), "sender not owner");
    _certificateHolder[contractAddress][tokenId].holder = address(0);
    emit ChangeHolder(contractAddress, address(0), tokenId);
  }

  function ownerOf(address contractAddress, uint256 tokenId) 
  public view Owner721Token(contractAddress) returns(address) {
    return _certificateHolder[contractAddress][tokenId].tokenOwner;
  }

  function holdOf(address contractAddress, uint256 tokenId)
  public view Owner721Token(contractAddress) returns(address) {
    return _certificateHolder[contractAddress][tokenId].holder;
  }

  function checkHolder(address contractAddress, address holderAddress, uint256 tokenId) 
  public view Owner721Token(contractAddress) returns (bool) {
    require(holderAddress != address(0), "zero holder address");
    address owner = _certificateHolder[contractAddress][tokenId].tokenOwner;
    require(owner == _msgSender(), "sender not owner");

    return _certificateHolder[contractAddress][tokenId].holder == holderAddress;
  }
}