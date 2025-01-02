
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
/*
0 message
1. hash(message) 就是上节讲的keccak256 
2. sign(hash(message), 私钥) | 链下过程，拿着私钥和hash之后的字符串进行签名
3. ecrecover(hash(message), signature) ==  signer | 链上拿着hash之后的信息+签名做ecrecover函数恢复地址如果等于signer，就是signer签署的信息

*/
contract VerifySig{
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns(bool){
        // signer 就是账户地址，message就是我们发送的信息，sig就是使用账户进行的签名
        // 1. 对message进行hash，keccak256函数
        bytes32 messageHash = getMessageHash(_message);
        // 2.我们要对messageHash做一个加工，在EVM链上做一个hash
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        // 3.拿着EVM里面的hash 与 签名sig恢复，如果等于_signer 说明是 signer就是签名的构造者 
        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message)public  pure returns (bytes32){
        return keccak256(abi.encodePacked(_message));
    }
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32){
        // 实际上在message前面增加了一个字符串，代表链下数据是以太坊链上的签名，链下实际钱包里签名，也是对这段字符串进行签名
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash));

    }
    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address){
        // 拿着我们编写好的Hash，和签名，来恢复签名地址，是否等于_signer,相等就说明是有效的
        // 对我们的签名做拆分，会分解成3个 r s v的数据
        (bytes32 r, bytes32 s, uint8 v) =_split(_sig);
        // 调用自带的ecrecover函数,就能恢复出来address地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function _split(bytes memory _sig) internal  pure returns(bytes32 r, bytes32 s, uint8 v){
        require(_sig.length==65, "invalid signature length  ");

        // 使用底层的汇编语言拿 r s v
        // signature 是动态的数据类型，前32字节 是sig的长度，因此需要跳过
        assembly{
            r := mload(add(_sig, 32))
            s :=mload(add(_sig, 64))
            v :=byte(0,mload(add(_sig,96)))
        }
    }
}

// 部署成功之后，获取到keccak256的Hash值  也就是加工过的hash
// 0:bytes32: 0x9c97d796ed69b7e69790ae723f51163056db3d55a7a6a82065780460162d4812

// 签名操作：需要再浏览器上使用Meta Mask(小狐狸钱包)对这段hash做签名
// 需要下载metamask插件，然后重启浏览器，并且复制accout的地址，在插件名称的下面如：account1: 0x3578B6f7B9BfB7e0C0D4e0E0f155ea671A55aa8e
// 使用小狐狸 metamask进行签名，输入以下代码，就会弹出小狐狸的插件，点击确定
// ethereum.request({method:"personal_sign", params:[account, hash]})
// 在promise里拿到返回的promiseResult 结果，就是签名 _sig
// [[PromiseResult]]: "0x9e022c3d0cf0e29d660e139f074e1b6396740cd7a5c3ec2c58a3313cec1b88d74d54305474b70e222f7fe24b1ea376632fcf7b2a65e7091b4950ef51812a13961c"
// 拿到签名之后就能调用recover 和verify了
// 比如 recover方法需要加工过的hash 和 _sig
// recover 之后拿到返回的地址：0: address: 0x3578B6f7B9BfB7e0C0D4e0E0f155ea671A55aa8e 和 上方账户account1 地址相同

