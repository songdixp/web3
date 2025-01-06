
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./051ERC20.sol";
// 实战练习：众筹合约
// 完成众筹目标、开始时间、结束时间
// 功能：创建众筹、取消众筹、参与众筹（另一个用户那他的token数量参与）、取消自己的众筹
// claim 达到众筹目标众筹创建者，就能把参与众筹的用户的token 按照数量提取出来
// refund 没有达到目标，参与众筹的用户可以把自己的token领回去

contract CrowdFund{
    event Launch(
        uint id, //众筹的活动id
        address indexed createor, // 活动创建者
        uint goal,
        uint32 startAt,
        uint32 endAt
    ); 
    event Cancel(uint id);
    // 众筹的id，众筹者的地址，参与众筹的数量，这次加上indexed是因为id可以查询出多个记录
    event Pledged(uint indexed id,address indexed caller, uint amount);
    event Unpledged(uint indexed id,address indexed caller, uint amount);
    event Claim(uint indexed id);
    event Refund(uint indexed id, address indexed caller, uint balance);
    // 先创建众筹的结构体
    struct Campaign{
        address creator;
        uint goal; //筹集token数量目标
        uint pledged; //所有众筹的总数量
        uint32 startAt;
        uint32 endAt;
        bool claimed; //是否被领取过 true 已经被创建者领取，只能领取一次
    }
    // 每一次众筹都要有对应的token，必须指定为一个固定的token地址，使用IERC20来定义
    IERC20 public immutable token;
    // 那么筹款活动的id来源可以通过计数器来得到,可以从1开始
    uint public count;
    // 筹款活动的id 对应筹款活动结构体，可以通过id 来找到筹款结构体的详细数据
    mapping(uint=>Campaign) public campaigns; 

    // 用户创建参与某个众筹活动的映射  {筹款活动的id :{用户地址: 筹款数额}}
    mapping (uint => mapping (address=> uint)) public pledgedAmount;

    // 初始化状态变量
    constructor(address _token){
        // 规定当前合约要使用哪一个 token地址
        token = IERC20(_token); 
    }

    // 开始编写函数
    // 创建众筹
    function launch(
        uint _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        // 开始时间要求在当前时间之后，结束时间要求在当前时间之后的90天内结束
        require(_startAt >= block.timestamp, "start time < now"); // 区块的时间戳，这个时间戳只在挖矿之后产生
        require( _endAt > _startAt,"end time < start time");
        require(_endAt < block.timestamp + 90 days, "end at > max duration"); // 90days就是智能合约自动计算出来的秒钟
        count += 1;//并且把这个计数当成主键
        campaigns[count] = Campaign({
            creator:msg.sender,
            goal:_goal,
            pledged:0,
            startAt:_startAt,
            endAt:_endAt,
            claimed:false
        });
        // 向链外汇报有一个众筹事件已经上限了
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
        
    }

    // 取消众筹活动
    function cancel(uint _id)external {
        // 不能再活动开始之后取消，先把活动结构体装载到内存中
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator!");
        require(block.timestamp < campaign.startAt, "has started can't cancel");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    // 参与众筹
    function pledged(uint _id, uint _amount)external {
        // 要修改众筹活动的变量
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.startAt, "not start");
        require(block.timestamp < campaign.endAt, "has ended!");

        campaign.pledged += _amount; //加上用户带过来的的数量
        pledgedAmount[_id][msg.sender] += _amount; //记录一下映射的数量，相当于同步
        token.transferFrom(msg.sender, address(this), _amount); // 修改数据完成之后就将参与者的token转移到当前合约中来
        
        emit Pledged(_id, msg.sender, _amount);

    }
    // 众筹回退
    function unpledge(uint _id, uint _amount)external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.endAt, "has ended!"); // 结束了就不能回退
        // require(_amount <= campaign.pledged, "value > pledged"); // 回退的金额不能超过已经众筹的金额，这个是我自己的判断

        campaign.pledged -= _amount; // 众筹总数减少，如果超过了金额，会有数学溢出的报错，所以不需要上面的判断
        pledgedAmount[_id][msg.sender] -= _amount; // 用户参与的众筹数量减少
        token.transfer(msg.sender, _amount); //返还token数量 不需要transferFrom了，因为是当前合约直接发送给用户

        emit Unpledged(_id, msg.sender, _amount);


    }

    // 领取众筹资金
    function claim(uint _id)external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledge < goal");
        require(!campaign.claimed, "has claimed!"); // 一次众筹只能领取一次

        campaign.claimed = true; // 要先修改已经领取的字段，这样再次调用就不会重复领取
        token.transfer(msg.sender, campaign.pledged); // 合约转给创建者，这里么有用creator因为msg.sender 就在内存中，更加节省gas

        emit Claim(_id);
    }

    // 撤回:当活动没有达成目标，活动失败的时候，用户可以取回参与活动的数额
    function refund(uint _id)external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledge > goal");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0; // 拿到用户众筹余额之后，要将该字段置空，否则再次调用的时候会重复
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender , bal);

    }
}

// 先部署ERC20 的合约，再部署众筹合约， 输入ERC20合约的token地址
// 用第一个账户创建活动 ，第二个账户参与活动，先给第二个账户mint token 100wei



