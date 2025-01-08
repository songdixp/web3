// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


contract GasGolf{
    /*
    如何节约gas？
    没有优化的消耗：transaction cost: 50760 gas
    1、将函数参数引用类型的变量由 memory 变成 calldata， transaction cost 49032 gas，节省接近1000多
    2、循环体中优化状态变量的写入逻辑，transaction cost	48821 gas 节省几百 
    3、短路，优化判断条件，如果前面的条件不满足，后面的条件就不会运算  transaction cost	48509 gas
    4、循环增量，++i  47435 gas 
    5、缓存数组的长度  47399 gas
    6、将数组的元素提前赋值到内存中  47231 gas
    */  

    uint public total;

    // [1,2,3,4,5,100]
    function sumIfEvenAdnLessThan99(uint[] calldata nums) external  {
        // 将状态变量拷贝到内存中
        uint _total = total;
        // for (uint i=0; i<nums.length; i+=1){
        // 循环过程中，每次都要读取数组的长度，也是浪费gas
        // for (uint i=0; i<nums.length; ++i){
        uint len = nums.length;

        for (uint i=0; i<len; ++i){
            // 将两个 bool判断和 if条件语句进行合并
            // bool isEven = nums[i] %2 ==0;
            // bool isLessThan99 = nums[i] < 99;
            // if (isEven && isLessThan99){
            uint num = nums[i];
            if (num %2 ==0 && num < 99){ 
                // 每次循环的时候都写入状态变量，这个操作浪费gas
                // 将数组变量提前赋值到内存中来
                // _total += nums[i]; 
                _total += num;

            }
        }
        // 循环结束之后将一次性的结果写入到状态变量中
        total = _total;
    }

}


