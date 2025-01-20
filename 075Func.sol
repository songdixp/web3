// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


contract XYZ{
    /*
    solidity 如果参数比较多，那么需要记住传过来的参数顺序，否则参数对不上，导致计算错误
    但是有 key value的方式来调用，无需记住参数的顺序 也能实现正确的对应
    */ 
    function someFuncWithManyInputs(
        uint x, uint y, uint z, address a, address b, string memory c
    )public pure returns(uint){

    }

    function callFuncWithKeyValue()external pure returns(uint ){
        return someFuncWithManyInputs({
            x:1,
            y:2,
            z:3,
            a: address(0), 
            b: address(0),
            c:"c"
        });
    }
}
