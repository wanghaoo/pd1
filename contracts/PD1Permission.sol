// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract PD1Permission is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => mapping(address => mapping(uint256 => Permission))) _grantPermission;
    struct Permission {
      uint256 permissionTag;
      string reason;
    }

    event PermissionChange(address indexed _owner, address indexed _user, uint256 indexed _tokenId, uint256 permission, string reason);

    modifier ZeroAddress(address addr) {
      require(addr != address(0), "zero address");
      _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint(address owner, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    /**
     * @dev Return if "permissionTag" is the permission granted to the user by the Token owner
     * @param _user granted user address
     * @param _tokenId granted token id
     * @param _permissionTag token permission tag
     */
    function access(address _user, uint256 _tokenId, uint256 _permissionTag) 
    external ZeroAddress(_user) view returns (bool) {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "gran caller is not owner nor approved");
      require(_permissionTag > 0, "permission tag not be zero");

      return _grantPermission[_msgSender()][_user][_tokenId].permissionTag == _permissionTag;
    }

    /**
     * @dev Return "permissionTag" is the permission granted to the user by the Token owner
     * @param _user granted user address
     * @param _tokenId granted token id
     */
    function permission(address _user, uint256 _tokenId) 
    external ZeroAddress(_user) view returns (uint256) {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "gran caller is not owner nor approved");

      return _grantPermission[_msgSender()][_user][_tokenId].permissionTag;
    }


    /**
     * @dev Grant "_tokenId" "_permisstionTag" to the "_to" address
     * @param _to granted to user address
     * @param _tokenId granted token id
     * @param _permissionTag token permission tag
     * @param _reason grant reason
     */
    function grant(address _to, uint256 _tokenId, uint256 _permissionTag, string memory _reason) 
    external ZeroAddress(_to) payable {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "gran caller is not owner nor approved");
      require(_permissionTag > 0, "permission tag not be zero");

      _grantPermission[_msgSender()][_to][_tokenId].permissionTag = _permissionTag;
      _grantPermission[_msgSender()][_to][_tokenId].reason = _reason;

      emit PermissionChange(_msgSender(), _to, _tokenId, _permissionTag, _reason);
    }

    /**
     * @dev Revoke "_to" user "_tokenId" tonken permission
     * @param _to revoke user address
     * @param _tokenId revoke token id
     */
    function revoke(address _to, uint256 _tokenId)
    external payable {
      _revoke(_to, _tokenId);
    }

    function _revoke(address _to, uint256 _tokenId)
    private ZeroAddress(_to) {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "gran caller is not owner nor approved");

      if (_grantPermission[_msgSender()][_to][_tokenId].permissionTag > 0) {
        _grantPermission[_msgSender()][_to][_tokenId].permissionTag = 0;
        _grantPermission[_msgSender()][_to][_tokenId].reason = "";

        emit PermissionChange(_msgSender(), _to, _tokenId, 0, "");
      }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public override {
      super.safeTransferFrom(from, to, tokenId, data);
      _revoke(to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
      super.safeTransferFrom(from, to, tokenId);
      _revoke(to, tokenId);
    }
}