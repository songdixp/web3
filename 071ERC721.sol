// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;



// 1 要实现的接口是IERC165
interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}

// 2 要实现的是IERC721 
interface IERC721 is IERC165{
    function balanceOf(address owner) external view returns (uint balance);
    function ownerOf(uint tokenId) external  view  returns(address owner);
    function safeTransferFrom(address from ,address to ,uint tokenId)external ;
    function safeTransferFrom(address from ,address to, uint tokenId, bytes calldata data) external ;
    function transferFrom(address from ,address to ,uint tokenId)external ;
    function approve(address to, uint tokenId) external ;
    function getApproved(uint tokenId) external view returns(address operator);
    
    function setApprovalForAll(address operator,bool _approved) external ;

    function isApprovedForAll(address owner, address operator) external view returns(bool); 

}

// 3 要实现IERC721Receiver 我们在收到一个NFT，在saveTransferFrom方法之后调用一下这个接收的方法
// 这里bytes 是引用数据类型，函数参数需要声明存储位置，使用calldata相比memory节省gas因为不需要复制到memory中。
interface IERC721Receiver {
    function onERC721Received(
        address operator, 
        address from , 
        uint256 tokenId, 
        bytes calldata data)
        external returns(bytes4);
}

// 也就是NFT 不可替代币
contract ERC721 is IERC721{
    event Transfer(address indexed from , address indexed to ,uint indexed id);
    event Approval(address indexed owner, address indexed spender, uint indexed id);
    event ApprovalForAll(address indexed owner,address indexed  operator ,bool approved);

    // 状态变量，代表NFTid属于谁
    mapping (uint=> address) internal _ownerOf;
    // 一个地址可能存在多个NFT
    mapping (address=> uint)internal _balanceOf;
    // alex允许Bob调用他某一个NFT tokeId 允许的地址，调用之后就记录了NFT的某个ID被谁使用了
    mapping (uint=> address) internal  _approvals;

    // Nested 二维数组，指定一个地址可以调用所有的NFT ID,这里使用public 可见性，因为接口中已经存在了相同名称的function，我们直接实现它
    mapping (address=> mapping(address=> bool)) public isApprovedForAll;

    function supportsInterface(bytes4 interfaceID) external pure returns(bool){
        // 固定写法
        // 入参的id 符合165 和721接口上d
        // type(接口名).interfaceId ，它会返回一个 bytes4 类型的值，这是接口的 EIP-165 接口标识符。
        return interfaceID == type(IERC721).interfaceId ||interfaceID ==type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external view returns (uint balance){
        require(owner != address(0), "owner == address 0");
        return _balanceOf[owner];
    }
    // 查询拥有者是谁 这里为什么不需要返回？ 不是已经有returns要求了吗
    function ownerOf(uint tokenId) external  view  returns(address owner){
        owner = _ownerOf[tokenId];
        require(owner != address(0), "owner = address 0");
    }
    // 授权操作员操作自己的NFT 
    function setApprovalForAll(address operator,bool _approved) external {
        isApprovedForAll[msg.sender][operator]= true;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }
    // 和approvalforall差不多,授权拥有者
    function approve(address to, uint tokenId) external {
        address owner = _ownerOf[tokenId];
        // 检查owner是否等于操作员，如果不等于，检查owner是否授权了操作员权限
        require(owner == msg.sender || isApprovedForAll[owner][msg.sender],"not authorized");
        _approvals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint tokenId) external view returns(address operator){
        // 传入tokenId来获取授权，返回授权地址
        // 要求这个NFT的id 的地址不能是0,是0 的就是不存在了
        require(_ownerOf[tokenId] != address(0), "tokenId not exist");
        return _approvals[tokenId];
    }
    
    function isApprovedOrOwner(address owner, address operator, uint tokenId) internal view returns (bool){
        // 检查tokenId是不是有权限被operator 出售、转移掉。
        return (operator == owner 
        || isApprovedForAll[owner][operator] 
        || operator == _approvals[tokenId]
        );

    }
    // 可见性public 需要外部和内部同时调用，因为safeTransferFrom也要调用，外部也要调用
    function transferFrom(address from ,address to ,uint tokenId) public {
        // 首先检查tokenId 的 from是不是owner
        require(from ==_ownerOf[tokenId], "from is not owner!");
        // 检查 tokenId的接受地址 to 不能是0
        require(to != address(0), "to is address 0");
        // 检查操作者有没有权限，是不是owner授权的操作者
        require(isApprovedOrOwner(from, msg.sender, tokenId), "msg.sender not Authorized!");

        _balanceOf[from] -- ; // 减少所有者的数量
        _balanceOf[to] ++ ; //增加to的数量
        _ownerOf[tokenId] = to; //更新 tokenId的所有者，从from 变成to

        delete _approvals[tokenId];
        emit Transfer(from , to, tokenId);

    }

    // 来实现safeTransFrom，不带data，单纯的调用
    function safeTransferFrom(address from ,address to ,uint tokenId)external {

        transferFrom(from, to, tokenId);
        // 检查接受的地址是不是合约,不是合约可以直接调用，因为我们可以把NFT转给一个正常的EOA地址
        // 是合约，需要检查 onERC721Received 的签名，与selector是否保持一致
        require(
            to.code.length ==0 || //等于0就是正常的EOA地址，可以接收NFT
            // 不是的话就是合约，需要调用 onERC721Received 方法
            // 不满足说明不安全，他那面没有准备好接收我们的NFT 
            IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, "") == IERC721Receiver.onERC721Received.selector, "unsafe recipient");
    }
    // 带data，将上面的空字符串 修改成data就好。
    function safeTransferFrom(address from ,address to, uint tokenId, bytes calldata data) external {
         transferFrom(from, to, tokenId);
        require(
            to.code.length ==0 || 
            IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) == 
            IERC721Receiver.onERC721Received.selector, "unsafe recipient");
    }

    // 写两个ERC721 没有规定必须要写，但是一般会加入 Mint Burn
    function _mint(address to, uint tokenId) internal {
        require(to !=address(0), "to is address(0)");
        require(_ownerOf[tokenId] == address(0), "tokenId exists!");

        _balanceOf[to] ++;
        _ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId)internal{
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "tokenId not exist");

        _balanceOf[owner] --;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];
        
        emit Transfer(owner, address(0), tokenId); 

    }
}

// 来实现一个简单的NFT
contract MyNFT is ERC721{
    function mint(address to, uint tokenId) external{
        _mint(to, tokenId);
    }
    function burn(uint tokenId) external{
        require(msg.sender == _ownerOf[tokenId], "not owner");
        _burn(tokenId);
    }
}

