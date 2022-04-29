// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Arrays.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract PD1Permission is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    Counters.Counter private _permissionPrimaryKey;

    mapping (bytes32 => uint256[]) _ownerTokenIndex;
    mapping (bytes32 => uint256[]) _grantUserTokenIndex;
    mapping (bytes32 => uint256) _grantUserTokenPermissionIndex;

    Permission[] _permissionTable;
    struct Permission{
      address owner;
      address grantUser;
      uint256 tokenId;
      uint256 permission;
      string resion;
    }

    mapping(address => uint256) _grantTokenUsers; // token -> 授权用户

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
     * @dev Return if "_permission" is the permission granted to the user by the Token owner
     * @param _user granted user address
     * @param _tokenId granted token id
     * @param _permission token permission tag
     */
    function access(address _user, uint256 _tokenId, uint256 _permission)
    external ZeroAddress(_user) view returns (bool) {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "grant caller is not owner nor approved");
      require(_permission > 0, "permission tag not be zero");
      
      bytes32 grantUserTokenPermissionKey = _buildGrantUserTokenPermissionIndex(_msgSender(), _tokenId, _user, _permission);
      if (_grantUserTokenPermissionIndex[grantUserTokenPermissionKey] == 0) {
        return false;
      }

      uint256 index = _grantUserTokenPermissionIndex[grantUserTokenPermissionKey];
      Permission memory permission_ = _permissionTable[index];

      return _user == permission_.grantUser && _tokenId == permission_.tokenId && _permission == permission_.permission;
    }

    /**
     * @dev Return "permissions" is the permission granted to the user by the Token owner
     * @param _user granted user address
     * @param _tokenId granted token id
     */
    function permission(address _user, uint256 _tokenId) 
    external ZeroAddress(_user) view returns (uint256[] memory) {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "grant caller is not owner nor approved");

      bytes32 key = _buildGrantUserTokenIndexKey(_msgSender(), _tokenId, _user);
      if (_grantUserTokenIndex[key].length <= 0) {
        return new uint256[](0);
      }

      uint256[] memory indexes = _grantUserTokenIndex[key];

      uint256[] memory result = new uint256[](indexes.length);
      for (uint256 i = 0; i < indexes.length; i ++) {
        Permission memory permission_ = _permissionTable[indexes[i]];
        result[i] = permission_.permission;
      }
      return result;
    }


    /**
     * @dev Grant "_tokenId" "_permission" to the "_to" address
     * @param _to granted to user address
     * @param _tokenId granted token id
     * @param _permission token permission tag
     * @param _reason grant reason
     */
    function grant(address _to, uint256 _tokenId, uint256 _permission, string memory _reason) 
    external ZeroAddress(_to) payable {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "grant caller is not owner nor approved");
      require(_permission > 0, "permission tag not be zero");

      // build access index
      bytes32 _grantUserTokenPermissionIndexKey = _buildGrantUserTokenPermissionIndex(_msgSender(), _tokenId, _to, _permission);
      require(_grantUserTokenPermissionIndex[_grantUserTokenPermissionIndexKey] == 0, "user token permission existend");

      // index permission
      _permissionPrimaryKey.increment();
      uint256 index = _permissionPrimaryKey.current();

      _grantUserTokenPermissionIndex[_grantUserTokenPermissionIndexKey] = index;

      _permissionTable[index] = Permission(_msgSender(), _to, _tokenId, _permission, _reason);

      //build clear permission index
      bytes32 _ownerTokenIndexKey = _buildOwnerTokenIndexKey(_msgSender(), _tokenId);
      _ownerTokenIndex[_ownerTokenIndexKey].push(index);

      // build permission index
      bytes32 _grantUserTokenIndexKey = _buildGrantUserTokenIndexKey(_msgSender(), _tokenId, _to);
      _grantUserTokenIndex[_grantUserTokenIndexKey].push(index);

      emit PermissionChange(_msgSender(), _to, _tokenId, _permission, _reason);
    }

    /**
     * @dev Revoke "_to" user "_tokenId" permission
     * @param _to revoke user address
     * @param _tokenId revoke token id
     */
    function revoke(address _to, uint256 _tokenId)
    external ZeroAddress(_to) payable {
      require(_isApprovedOrOwner(_msgSender(), _tokenId), "gran caller is not owner nor approved");

      bytes32 _ownerTokenIndexKey =  _buildOwnerTokenIndexKey(_msgSender(), _tokenId);
      require(_ownerTokenIndex[_ownerTokenIndexKey].length > 0, "grant user token nonexistend");

      uint256[] memory permissionTableIndex = _ownerTokenIndex[_ownerTokenIndexKey];

      for (uint256 i = 0; i < permissionTableIndex.length; i ++) {
        uint256 _permission = _permissionTable[permissionTableIndex[i]].permission;
        delete _permissionTable[permissionTableIndex[i]];
        _removeGrantUserTokenPermissionIndex(_msgSender(), _tokenId, _to, _permission);
      }
      _removeOwnerTokenIndex(_msgSender(), _tokenId);
      _removeGrantUserTokenIndex(_msgSender(), _tokenId, _to);

      emit PermissionChange(_msgSender(), _to, _tokenId, 0, "");
    }

    /**
     * @dev clear permission when transfer
     */
    function _clearTokenPermission(address _from, uint256 _tokenId)
    private {
      bytes32 _ownerTokenIndexKey =  _buildOwnerTokenIndexKey(_msgSender(), _tokenId);
      if (_ownerTokenIndex[_ownerTokenIndexKey].length <= 0) {
        return;
      }

      uint256[] memory permissionTableIndex = _ownerTokenIndex[_ownerTokenIndexKey];

      for (uint256 i = 0; i < permissionTableIndex.length; i ++) {
        Permission memory _permission = _permissionTable[permissionTableIndex[i]];

        delete _permissionTable[permissionTableIndex[i]];
        _removeGrantUserTokenIndex(_from, _tokenId, _permission.grantUser);
        _removeGrantUserTokenPermissionIndex(_from, _tokenId, _permission.grantUser, _permission.permission);

        emit PermissionChange(_from, _permission.grantUser, _tokenId, 0, "");
      }
      _removeOwnerTokenIndex(_from, _tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
      super.safeTransferFrom(from, to, tokenId);
      _clearTokenPermission(from, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public override(ERC721) {
      super.safeTransferFrom(from, to, tokenId, data);
      _clearTokenPermission(from, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
      super.transferFrom(from, to, tokenId);
      _clearTokenPermission(from, tokenId);
    }

    function _buildOwnerTokenIndexKey(address _owner, uint256 _tokenId) 
    internal pure returns(bytes32) {
      return keccak256(abi.encodePacked(_owner, "::", _tokenId.toString()));
    }

    function _buildGrantUserTokenIndexKey(address _owner, uint256 _tokenId, address _to) 
    internal pure returns(bytes32) {
      return keccak256(abi.encodePacked(_owner, "::", _tokenId.toString(), "::", _to));
    }

    function _buildGrantUserTokenPermissionIndex(address _owner, uint256 _tokenId, address _to, uint256 _permission) 
    internal pure returns(bytes32) {
      return keccak256(abi.encodePacked(_owner, "::", _tokenId.toString(), "::", _to, "::", _permission));
    }

    function _removeOwnerTokenIndex(address _owner, uint256 _tokenId) internal {
      delete _ownerTokenIndex[_buildOwnerTokenIndexKey(_owner, _tokenId)];
    }

    function _removeGrantUserTokenIndex(address _owner, uint256 _tokenId, address _to) internal {
      delete _grantUserTokenIndex[_buildGrantUserTokenIndexKey(_owner, _tokenId, _to)];
    }

    function _removeGrantUserTokenPermissionIndex(address _owner, uint256 _tokenId, address _to, uint256 _permission) internal {
      delete _grantUserTokenPermissionIndex[_buildGrantUserTokenPermissionIndex(_owner, _tokenId, _to, _permission)];
    }
}