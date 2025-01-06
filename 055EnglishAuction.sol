
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


// 英式拍卖
// 正常的拍卖，出价高的人获得
// 设置起始时间、结束时间，出价最高的人赢得拍卖的物品
// 拍卖内容ERC721NFT的token

interface IERC721 {
    function transferFrom(
        address _from, 
        address _to,
        uint _nftId
    ) external;
    
}
contract EnglishAuction{
    // 10 定义start事件, 这个事件不需要参数，因为已经有足够的状态变量来记录了
    event Start();
    // 参与拍卖者的地址增加索引，这样就能在链外进行批量查询
    event Bid(address indexed sender, uint amount);
    // 取款事件 竞拍者取回的以太数量
    event Withdraw(address indexed bidder, uint amount);
    event End(address hightestBidder, uint highestBid); //结束事件只会触发一次，没必要增加索引

    // 1、确定ERC721的token地址,同时是不可变量在构造函数的时候进行赋值
    IERC721 public immutable nft;
    // 2、指定当前合约可以操控哪个NFT, 当前合约只针对同一个nft，也就是只能拍卖这一个nft id，想要拍卖更多的，只能在创建合约去拍卖
    uint public immutable nftId;
    // 3、地址变量，也是不可变的，规定了销售者的地址,谁出售的这个nft
    address  payable public  immutable seller;
    // 4、规定拍卖的结束时间 uint32 2**32 已经是100多年的长度了，足够使用
    uint32 public endAt;
    // 5\定义拍卖是否已经开始了、结束了 
    bool public started;
    // 6、已经结束
    bool public ended;

    // 针对购买者创建一些变量
    // 7、最高的出价者
    address public hightestBidder;
    uint public highestBid;
    // 8、定义mapping 每一个出价者的出价，因为需要将其他低于最高价的出价者的ETH退换给对应的人
    mapping (address=> uint )public bids;

    // 创建构造函数,构造好NFT的地址，拍卖的哪一个具体的NFT的id，起拍价格是多少
    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ){
        nft = IERC721(_nft); //使用nft的状态变量存入 我们输入的nft的地址
        nftId = _nftId;  // 将输入的nftId 赋值到状态变量中
        // 将销售者定义成合约的部署者，但是我们需要将购买者的主币发送给合约的部署者,所以销售者的地址得是payable类型的
        seller =payable( msg.sender);  
        highestBid = _startingBid; // 起拍价格开始的时候是最高价格 
    }

    // 9 开始定义函数，开始拍卖()
    function start() external {
        require(seller == msg.sender, "not seller"); // 必须由销售者调用
        require(!started, "has started!"); // 必须没有开始
        // 修改状态变量
        started =true; // 修改成已经开始
        endAt = uint32(block.timestamp + 120); //  因为状态变量是 uint32 类型的，block是uint256 类型的需要进行转换才能使用，测试 时间可以使7 days ，这里60 就是秒
        nft.transferFrom(seller, address(this), nftId); // 把nft发送到这个合约上面，发送的是其他人账户的nft
        // 这里的别人还是部署合约的人啊，部署合约的人就是销售者，所以就是销售者调用开始的方法，把自己账户的nft发送到这个合约上

        //10 定义一个发送的日志事件
        emit Start();
    }

    // 11 定义拍卖的方法
    // 由参加拍卖的用户调用，还发送以太，所以需要是payable
    function bid()external payable {
        require(started, "not start!");
        require(block.timestamp < endAt, "bid is ended!");
        require(msg.value > highestBid, "value < highestBid");
        if (hightestBidder !=address(0)){
            // 上一次最高出价者的出价做一个累加，如果上一个竞标者没有竞标成功，可以根据这个累加记录，来进行退还
            // 并且第一次有人出价的话，上一次就是0地址
            bids[hightestBidder] += highestBid;
        }
        
        // 更新状态变量
        highestBid = msg.value;
        hightestBidder = msg.sender;
        

        // 退还上一次的最高出价者的主币
        emit Bid(msg.sender, msg.value);


    }
    // 12 如果你的出价被下一个最高价覆盖之后，你就可以把之前咋地额出价取回了，所以要设置取回方法
    function withdraw()external {
        // 即使最高价还是你自己，你仍然可以取回上一次出价
        uint bal = bids[msg.sender] ; //拿到当前调用者的出价数量,也就是之前记录的累计出价
        bids[msg.sender] = 0; //拿出来之后就归零，防止漏洞发生
        // 如果不将bidPrices中的值归零，可能会出现重入攻击（Reentrancy Attack）
        // 最后在发送主币，发送到msg.sender地址上
        payable (msg.sender).transfer(bal);
        emit  Withdraw(msg.sender, bal);
    }
    // 13 最后一个方法，结束拍卖
    function end() external {
        // 特性：任何人都可以调用它，不需要确认调用者的身份，不管谁调用，改变的状态是确定的，都是我们想要的结果
        // 能不确认的工作就不要做，否则浪费gas
        require(started, "not start");
        require(!ended, "has ended!");
        require(block.timestamp >= endAt, "now <= end time!");

        ended = true;
        if (hightestBidder != address(0)){
            // 把nft 的id从这个合约发送到最高出价者的地址上
            nft.transferFrom(address(this), hightestBidder, nftId);
            // 然后把合约中的主币发送到销售者的地址上
            seller.transfer(highestBid);
            // 考虑最后一种情况，如果这次拍卖没有任何人出价，但是nft的id还锁在合约里面,只有最高出价者不是0地址，才代表我们出过价
        }else{
            // 没有任何人出价，就退还到销售者的账户中,合约中没有主币，也不用transfer主币
            nft.transferFrom(address(this), seller, nftId);
        }
        
        emit End(hightestBidder, highestBid);
    }

}

// 测试部署
// 先部署标准的ERC721 合约，我们的代码是 MyNFT 才有mint方法，铸造一个主币
// 使用第一个账户地址，mint出来一个主币 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// id： 123，这样就发送给第一个默认账户了

// 部署英式拍卖合约
// 先输入构造函数的参数 _NFT _NFTID _startingbid
// 1 NFT 合约的地址 ： 0x9F2b8EAA0cb96bc709482eBdcB8f18dFB12D3133
// 2 NFTID ：123 要拍卖的NFT
// 3 起拍价格  1wei 就够了

// 开始拍卖前还有事情，如果要把 NFT 发送给拍卖合约，就必须要针对 拍卖合约，做approve授权
// 步骤：MyNFT 合约中 approve 方法，输入 批准的合约地址，也就是 拍卖合约地址 + nftid
// 也就是在ERC721 合约中批准 123号tokenid的控制权，接下来就可以拍卖了

// 开始拍卖
// start () 交易成功
// 切换账号，Ab8 第二个账户参与拍卖，带着10wei主币参与拍卖， bid()，参与成功


