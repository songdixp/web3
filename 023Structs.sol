// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 结构体，允许把不同类型的数据分组，并放到一起
contract Structs{
    struct Car{
        string  model;
        uint year;
        address owner;
    }

    // 声明结构体方式
    Car public  car; //直接声明
    Car[] public cars; // 结合数组的方式声明
    mapping (address=> Car[]) public carsByOwner; //结合mapping的方式声明状态变量；


    // 初始化结构体
    function examples()external {
        //  1 第一种初始化的方式 声明数据结构  存储位置（函数结束之后就消失）命名名称 = 数据结构(想要声明的数据，按照顺序来写)
        Car memory toyota = Car("Toyota", 1990, msg.sender);
        // 2 声明方式 按照key value的形式来进行声明，不需要按照顺序来编写，推荐这种方式
        Car memory lambo = Car({model:"lambogni", year:123, owner:msg.sender});
        // 3 直接声明车子每个数据类型有默认值
        Car memory tesla;
        // 3.1 声明之后可以对值进行赋值
        tesla.model = "Tesla";
        tesla.year = 2010;
        tesla.owner = msg.sender;

        // 以上的三种方式声明都是在内存中的，执行完成函数之后三辆车就不存在了，需要把生命的三种车推送到状态变量里面
        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla); 

        // 除了以上三种方式，我们还可以使用一行代码直接推送到我们的车子数组里面
        cars.push(Car("avalon", 2098,msg.sender)) ;

        // 如何读取状态变量里面的数据？
        // 先声明Car 因为结构体的类型是数组，因此先读取固定位置，因为只需要读取不需要改变状态变量，变量名不要重名
        Car memory _car = cars[0];
        _car.model;
        _car.year;
        _car.owner;
        // 如果不仅仅是需要读取状态变量，还需要修改状态变量，就不能声明在内存中
        // storage 会在链上修改状态数据
        Car storage _car1 = cars[1];
        _car1.model = "big chancar";
        _car1.year =1989;
        _car1.owner = msg.sender;

        // 删除一些字段
        delete _car.owner; // 这样字段就变成了默认值 
        delete cars[1]; // 这样是对struct进行操作，这不是说struct在数组1的位置就空了，而是会把1位置的struct字段重置为默认值
    }


}
