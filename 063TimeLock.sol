// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


/*
时间锁合约一般应用在 Dapp上面 如DeFi类的去中心化金融，项目中需要有时间锁保护管理员权限
如果合约要进行重要的操作，必须还在队列中等待48小时+，我们就能在队列中看到这样的操作具体的内容是什么，如果是作恶的操作，就可以即时的取消他
*/ 

contract TimeLock{
    

    // 定义一个管理员，因为只有管理员才能操作时间锁
    address public owner;

    mapping (bytes32 => bool) public queued; // 记录到队列中是否存在

    error NotOwnerError(); // 自定义报错
    error AlreadyQueuedError(bytes32 txId); // 队列中已经存在id
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint blockTimestamp, uint timestamp);
    error TimestampExpiredError(uint blockTimestamp, uint expiredAt);
    error TxFailedError();

    
    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string  func,
        bytes  data,
        uint timestamp
    );

    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string  func,
        bytes  data,
        uint timestamp
    );

    event Cancel(bytes32 txId);

    receive() external payable { }

    uint public constant MIN_DELAY =10;
    uint public constant MAX_DELAY =1000;
    uint public constant GRACE_PERIOD =1000;


    constructor (){
        // 合约部署着就是管理员
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if (msg.sender != owner){
            revert NotOwnerError();
        } 
        _;
    }

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    )public pure returns(bytes32 txId){
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    )external  onlyOwner{
        //  队列中定义交易的id号
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        // 检查交易的id是否已经存在，通过映射的方式来进行检查
        if (queued[txId]){
            revert AlreadyQueuedError(txId);
        }
        // 时间戳的检查，交易执行的时间,在最小的执行延迟 到最大的执行延迟阶段，是可以有效的执行交易的
        // ------|--------------|----------------|---------
        //     block      block+min          block +max
        if (_timestamp < block.timestamp +MIN_DELAY || _timestamp> block.timestamp +MAX_DELAY){
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        // 记录交易id 到队列中
        queued[txId] = true; 

        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    // 执行方法，可能接受主币，所以也要编写接收方法 recevied
    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable onlyOwner returns(bytes memory){
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // 检查id是否在队列中
        if(!queued[txId]){
            revert NotQueuedError(txId);
        }
        // 检查时间戳是否有效，只需要验证当前时间戳是否大于录入的时间戳，范围在队列函数中验证过了
        if (block.timestamp < _timestamp){
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        // 当前的时间超过了指定时间太久了怎么办，定义一个宽限期的概念
        // ---------| ----------------|---------
        //      timestamp       timestamp+grace period
        if (block.timestamp>_timestamp+GRACE_PERIOD){
            revert TimestampExpiredError(block.timestamp, _timestamp+GRACE_PERIOD);
        }

        // 删除交易id
        queued[txId] = false;

        // 调用的底层编码 函数的名称、参数进行底层的abi编码
        // 但是调用有可能是对方合约的回退函数，如果函数名称的长度 >0  证明调用的是方法不是回退函数，再进行编码
        bytes memory data;
        if (bytes(_func).length > 0){
            data = abi.encodePacked(
                bytes4(keccak256(bytes(_func))), _data
            );
        }else{
            // 如果是回退函数，直接调用就可以
            data = _data;
        }


        // 执行交易, 目标地址执行底层 call 方法调用执行
        (bool ok , bytes memory res) = _target.call{value:_value}(data);
        if (!ok ){
            revert TxFailedError();
        }
        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return res;
    }

    // 取消方法，如果队列中的交易，被我们发现并不是合理的，就需要取消
    function cancel(bytes32 _txId) external onlyOwner{
        if (!queued[_txId]){
            revert NotQueuedError(_txId);
        }
        // 不是false 就修改值
        queued[_txId] = false;
        emit Cancel(_txId);


    }
}


contract TestTimeLock{
    address public timeLock;

    constructor (address _timeLock){
        timeLock = _timeLock;
    }
    function test()external view {
        require(msg.sender == timeLock, "not owner");
        // 用户调用时间锁合约，把要进行的操作推到时间锁合约的队列中，等待时间锁合约到达之后，调用执行 execute方法
        // 就会将用户操作的执行，被执行的合约把权限交给了时间锁合约，任何的合约都必须经历一个时间的锁定期 才能进行想要的操作
    }

    function getTimestamp() external view returns(uint ){
        return block.timestamp +100;
    }
}

/*
部署测试
部署时间锁 TIMELOCK 合约，部署TEST_TIME_LOCK 测试合约输入 时间锁合约 的地址，进行部署
通过时间锁 调用 Test_time_lock 合约的 test() 方法

*/ 

