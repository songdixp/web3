// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;



contract MostSignificantBit{
    // 最高有效 bit 位
    /*
    假设 101010 那么最高有效位就是1  位置就是 7，从左往右数
    返回值 uint8 能覆盖 256的所有位数 2**8 =256 能返回所有位数的可能性
    二分法来进行判断：是不是等于128次方 64次方...
    x >= 2 ** 128
    x >= 2 ** 64
    x >= 2 ** 32
    ...
    x >= 2 ** 1
    */ 
    
    function findMostSignificantBit(uint256 x) external pure returns(uint8 r){
        if(x >= 2 ** 128){
            x >>= 128;
            r += 128;
        }

        if(x >= 2 ** 64){
            x >>=64;
            r+= 64;
        }

        if(x >= 2 ** 32){
            x >>=32;
            r+= 32;
        }

        if(x >= 2 ** 16){
            x >>=16;
            r+= 16;
        }
        
        if(x >= 2 ** 8){
            x >>=8;
            r+= 8;
        }
        if(x >= 2 ** 4){
            x >>=4;
            r+= 4;
        }
        if(x >= 2 ** 2){
            x >>= 2;
            r+= 2;
        }
        if(x >= 2 ** 1){
            r+=1;
        }
    }
    
}



