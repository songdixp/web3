
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/*
1 引言
- 简要介绍 ERC 标准在以太坊生态系统中的重要性。 
-介绍 ERC20 和 ERC721 是最常见的两种代币标准。

/2.**ERC20**
- **定义**：什么是 ERC20。
- **可替代代币 （Fungible Tokens） ** 
-解释可替代性概念。，每个代币都是等值的，类似现实世界的法币，美元、人民币
-实例：USDT、DAI 等稳定币。USDT是和美元1:1锚定的货币

**核心功能** 也就是项目里面必须要实现的方法
- totalSupply  返回代币的总供应量，类似美元的发行量
- balanceof。返回某个地址的代币余额
- transfer  转账功能，把token从一个地址转移到另外一个地址
-‘approve’和'transferFrom'  授权其他账户代表自己来进行转账，
    如授权你，把我的钱给别人，我要授权一部分额度给你，合约上记录这比额度之后，你才能通过调用transferFrom把我的余额转给其他人
-allowance  查询我允许你的额度

- **应用场景**
    -创建代币、稳定币，治理代币，DeFi 项目流动性代币（比如 ELP）等。Cryptokitties 加密猫


3. **ERC721**
-**定义**：什么是 ERC721。
- **是不可替代代币 （Non-Fungible Tokens，NFT） 
    与ERC20 不同的地方在于721 代币标准都是独一无二的，有独特的id（标识符）
- 解释不可替代性概念。 
    每个代币在某个程度上是独特的，无法与其他代币进行互换，如即使数字产品可能生成于同一个智能合约，但是有这个ID就能区分开。

- 实例：数字艺术品、游戏道具、虚拟地产等。 最有名的： Borred Ape Yacht Club 

**核心功能**
- 'ownerof' 多了一个字段，查询每个ID的所有者 如 id=1 钱包地址为多少 id=2 钱包地址是多少，可能id1、2都是一个智能合约的地址
/
-balanceof' 查询某一个地址NFT下面的数量
/
‘transferFrom 也是代币，因此可以进行交易
-‘approve和‘getApproved
-safeTransferFrom 更安全的转移方法，可以确保接收方能够接收到的NFT，
    比如，接收方是一个合约/钱包地址，合约没有ERC721方法的话，就会被锁到里面，因此会检查是否包含处理721的方法
/
- **应用场景**
-数字艺术品、虚拟物品、虚拟土地等。

/4.**ERC20 与 ERC721 的区别**
- **代币类型**：可替代vs。不可替代。
-**应用场景**：金融支付（DeFi） vs。数字资产（NFT）。
-**功能侧重点**：批量转移 vs 唯一性管理。

*/


