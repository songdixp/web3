
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 通过角色来判断是否有调用函数的权限
contract AccessControl{
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    // role=》account=〉bool 
    // 创建双重的mapping ，如admin角色下面有alex账户地址，alex账户下面（二层mapping）存在admin的权限 bool
    // 为什么使用bytes32 ？因为如果角色名称过长我们会对名称进行hash，这样就都是固定长度 bytes32，节省一些gas
    mapping(bytes32=> mapping(address => bool)) public roles;
    // 定义admin private 相比public节省gas，定义产量不会变化也会节省一些，
    // public admin 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private   constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // public user 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 private  constant USER = keccak256(abi.encodePacked("USER"));

    modifier onlyRole(bytes32 _role){
        // 删除交易的角色
        require(roles[_role][msg.sender], "not authrized!");
        _;
    }

    constructor(){
        // 构造函数创建ADMIN角色
        _grantRole(ADMIN, msg.sender);
    }
    

    // 授权函数定义成 internal，这样别的合约继承之后就能进行授权
    function _grantRole(bytes32 _role, address _account) internal {
        // 更新 public的roles 嵌套mapping
        roles[_role][_account] =true;
        emit GrantRole(_role, _account);
    }
    // 外部调用不希望任何人都能调用，需要赋予角色权限才可以，需要进行modify限制
    function granteRole(bytes32 role, address account) external onlyRole(ADMIN){
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) external onlyRole(ADMIN){
        roles[role][account]=false;
        emit RevokeRole(role,account);
    }

}
// 通过拿到admin user的地址，修改为private可见性再次部署
// 传入 admin的bytes32的地址，以及当前account的地址 不是部署完成之后的合约地址
// 其中 account地址在部署合约的时候会生成，因此切换account再挑些到roles 里面的时候就为false
