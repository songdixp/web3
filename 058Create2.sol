

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


// 继续讲解通过合约部署合约的方法，但是是create2的方法
contract DeployWithCreate2{
    address public owner;

    constructor(address _owner){
        owner = _owner;
    }
}


contract Create2Factory{
    event Deploy(address addr);

    function deploy()external {
        
    }
}
