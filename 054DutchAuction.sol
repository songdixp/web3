
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 编写荷式拍卖
// 卖家会设置一个比较高的价格，买家开始就不来购买，随着商品的流逝会对商品逐渐的进行打折，时间越长，价格越低，价格合适了才会购买
interface IERC721{
    function transferFrom(address _from, address _to, uint _nftId) external ;
    
}

contract DutchAuction{
    uint private constant DURATION = 7 days;

    IERC721 public immutable nft721;
    uint public immutable nftId;

    address public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    constructor(uint _startingPrice, uint _discountRate, address _nftAddr, uint _nftId){
        // 买方 卖方我还是分不清楚，msg.sender 不是合约的调用者么？为什么要初始化成为 msg.sender
        seller = payable (msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;

        require(
            _startingPrice >= _discountRate *DURATION, // 开始价格不能在持续时间结束之后小于0
            "starting price < discount!"
        );
        nft721 = IERC721(_nftAddr);
        nftId = _nftId;
    }
    function getPrice()public view returns(uint){
        uint timeElapsed = block.timestamp - startAt; //拿到经过时间
        uint discount= discountRate *timeElapsed; //拿到优惠多少钱
        return startingPrice - discount; // 最终时间肯定是要让价格大于等于我们的费率 * 总的持续时间 
    }
    // 买家调用来购买nft
    function buy()external payable {
        require(block.timestamp < expiresAt, "aution expired");
        uint price = getPrice();

        require(msg.value >= price,"ETH < current price ");
        nft721.transferFrom(seller, msg.sender, nftId);
        // 买家买的多了，需要退款
        uint refund = msg.value-price;
        if (refund >0){
            payable (msg.sender).transfer(refund);
        }

    }

}


