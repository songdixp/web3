

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/*
了解Solidity 0.8中的溢出和下溢⾏为 
学习如何使⽤ unchecked 块禁⽤溢出和下溢检查
⽐较启⽤和禁⽤检查时的Gas费⽤

1.溢出和下溢概述
 •Solidity 0.8中默认启⽤的溢出和下溢检查
  •禁⽤这些检查可以节省Gas费⽤

2.使⽤ unchecked 禁⽤溢出和下溢检查
•⽰例：加法函数（add）
 ◦正常加法可能溢出，触发错误
 ◦使⽤ unchecked 块禁⽤溢出检查
 ◦⽐较禁⽤和启⽤检查的Gas费⽤
•⽰例：减法函数（subtract）
 ◦正常减法可能下溢，触发错误
 ◦使⽤ unchecked 块禁⽤下溢检查
 ◦⽐较禁⽤和启⽤检查的Gas费⽤

3.多⾏代码中的 unchecked 块
•⽰例：计算两个数的⽴⽅和（sum of cubes）
 ◦在unchecked 块中执⾏多⾏代码
 ◦禁⽤溢出和下溢检查
*/ 