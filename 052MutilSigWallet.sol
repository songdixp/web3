// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;



// 实现一个多签钱包，如果能实现的化，简单到中等的难度实现起来都没有问题

contract MutilSigWallet{
    // 用户存款的时候就发出这样一个事件
    event Deposit(address indexed sender , uint amount);
    // 提交一笔交易的时候触发这个事件 transcation缩写就是tx
    event Submit(uint indexed  txId);
    // 批准事件,合约的主人允许这比合约执行
    event Approve(address indexed owner, uint indexed txId);
    // 回滚事件 合约主人允许之后还可取消这比交易
    event Revoke(address indexed owner, uint indexed  txId);
    // 执行事件 一旦满足允许的交易数量之后，就会执行我们的交易
    event Execute(uint indexed txId);

    // 定义交易的结构
    struct Transcation{
        address to; //目标地址
        uint value; //多少以太
        bytes data; // 携带的数据是多少
        bool executed; //是否被执行过
    }

    // 定义状态变量
    address[] public owners; // 多签持有者的数组
    mapping (address=>bool) public isOwner; // 记录这个地址是不是多签持有人
    // 设置最小要求,不能大于owner的数组长度，以及最小的要求
    uint public threshold; //多签执行交易的门槛，需要多少人签名才能交易
    Transcation[] public transcations; // 声明交易结构体
    mapping(uint=> mapping (address=>bool)) public approved; //{交易id:{"0xowner的地址":是/否 允许}} 拿到交易id之后，看一下这笔交易的的owner是否允许交易 
    
    // 修饰函数
    modifier onlyOwner(){
        // 检查msg.sender是不是owner，有两种方式
        // 1 循环owners数组，2 直接使用isOwnermapping 更加节省gas
        require(isOwner[msg.sender], "not owner");
        _;
    }
    modifier txExists(uint _txId){
        // 要求txId大于数组长度
        require(_txId<transcations.length, "txId does not exists");
        _;

    }
    modifier notApproved(uint _txId){
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted(uint _txId){
        require(!transcations[_txId].executed, "tx already executed");
        _;
    }

    // 状态变量定义完成，需要进行构造函数的初始化 
    constructor(address[] memory _owners, uint _threshold){
        require(_owners.length >0,"owners is empty");
        require(_threshold>0  &&  _threshold<=_owners.length,"invalid threshold number"); 

        for (uint i;i<_owners.length;i++){
            address owner = _owners[i]; //拿到每一个owner
            require(owner !=address(0), "owner is address 0"); // 判断owner不能等于0
            require(!isOwner[owner], "owner must be unique");//判断全新owner地址

            isOwner[owner] = true;
            owners.push(owner);
        }
        threshold = _threshold;
    }

    receive() external payable { 
        emit Deposit(msg.sender, msg.value); // 发送以太的日志信息
    }

    // 下面编写submit函数，一旦owner提交的内容被 最低门槛的签名验证通过，就可以execute
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        //一行代码直接出初始化结构体，并且推送到状态变量中进行存储
        transcations.push(Transcation({
            to: _to, 
            value: _value, 
            data: _data, 
            executed: false     
        }));
        emit Submit(transcations.length-1);
    }

    // 编写 approve 函数设置交易的拥有者为true
    function approve(uint _txId)
        external 
        onlyOwner 
        txExists(_txId) 
        notApproved(_txId) 
        notExecuted(_txId)
        {
            approved[_txId][msg.sender] = true;
            emit Approve(msg.sender, _txId);
        }
    // 计算这笔交易 txId 被 approved 的数量，以便于达到最小的门槛数量要求
    function _getApprovalCount(uint _txId) private view returns(uint count){
        // 遍历owners数组，带入到approved mapping查询是否允许了
        for (uint i; i<owners.length;i++){
            if (approved[_txId][owners[i]] == true){
                count +=1;
            }
        }
        //不需要return 在返回参数中定义过了
    }

    //执行交易的函数，也就是修改交易结构体中的executed字段，要先满足最小的交易数量之后才行能执行交易
    // 也就是允许交易的数量要大于门槛数量，其中门槛数量要求是在函数初始化的时候传入的，传入的时候也有一定的要求才能设置成功
    function execute(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId)>= threshold); //满足大于门槛的数量才能执行交易
        Transcation storage transcation = transcations[_txId];
        transcation.executed = true; //所谓执行就是修改字段
        // 使用low level的形式传入以太
        // to 在submit函数中提交过了
        (bool success,)=transcation.to.call{value:transcation.value}(
            transcation.data
        );
        require(success,"tx failed");
        emit Execute(_txId);
    }

    // 撤销允许的函数
    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }  

}
