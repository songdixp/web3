// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


contract BitwiseOps{
    // 与运算
    function add(uint x, uint y) external pure returns(uint ){
        // 把入参都写成二进制 01组成，两位在相同位置都是1 就输出1， 否则都是0 
        // x = 1110 = 8+4+2+0 = 14
        // y = 1011 = 8+0+2+1 =11
        // x & y = 1 0 1 0 = 8+0+2+0 = 10
        return x  & y;
    }
    // 或运算
    function or(uint x, uint y) external pure returns(uint ){}
    // 异或运算
    function xor(uint x, uint y) external pure returns(uint ){
        // 必须是 01 或者 10 才能返回1，否则都是0
         return x ^ y;
    }
    // 非运算
    function not(uint8 x) external pure returns(uint ){
        // 没有用256 如果使用，还传入一个很小的数值，得出的数字会很大
        // x = 0001100 = 0 + 0 +0+8+4+0+0
        // ~x = 1110011 =  128+64+32+0+0+2+1=243
        return ~x;
    }
    // bit左移运算
    function shiftLeft(uint x, uint bits) external pure returns(uint ){
        // 0011 <<1 0110
        // 0001 <<2 0100
        return x << bits;
    }
    // bit右移运算
    function shiftRight(uint x, uint bits) external pure returns(uint ){
        // 1000 >> 1 0100
        // 1000 >> 4 0000
        return x >>bits;
    }


    function getLastNBits(uint x, uint n)external pure returns (uint ){
        // 输入13，怎样得到后面的三位 也就是 101
        // 可以使用IP的子网掩码的方式
        // x     1101
        // mask  0111
        // 两者做与运算 0101
        // 如何拿到 0111？ 让1 左移n位，再 -1 就能拿到掩码
        // 1 << 3 1000 -1 = 0111
        // 计算过程如下
        //   0 1 1
        //   1 0 0 0
        // - 0 0 0 1
        //     1 1 1
        uint mask = (1 << n) -1;
        return x & mask;
    }
    // 菜单
    function getLastNBitUsingMod(uint x, uint n) external pure returns(uint){
        // return x % (2**n);
        return x % (1 << n);        
    }

}



