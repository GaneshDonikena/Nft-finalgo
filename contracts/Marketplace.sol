// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is ReentrancyGuard, Ownable{
    
    //state variables
    address payable public immutable feeAccount;
    uint public immutable feePercent;
    IERC20 public tokenAddress;
    uint public itemCount;

    //structs
    struct Item{
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }

    event Offered(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    //mappings
    mapping(uint => Item) public items;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint => address) public tokenOwner;
    
    //constructor
    constructor(uint _feePercent, address _tokenAddress){

        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
        tokenAddress = IERC20(_tokenAddress); 

    }

    function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrant{
        require(_price > 0, "price must be greater than zero");
        itemCount++;
        tokenOwner[_tokenId] = msg.sender;
        allowance[msg.sender][address(this)] = _tokenId;
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        
        //emit Offered
        emit Offered(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );

    }

    function purchaseItem(uint _itemId, uint _tokenId) external payable nonReentrant{

        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(tokenAddress.balanceOf(msg.sender) >= _totalPrice, "not enough token to cover the item");
        require(!item.sold, "item already sold");

        //pay seller and fee Account
        tokenAddress.transferFrom(msg.sender, address(this), item.price);
        tokenAddress.transferFrom(msg.sender, address(this), (_totalPrice - item.price));

        //update the item as sold
        item.sold = true;

       //transfer the nft 
       item.nft.transferFrom(tokenOwner[_tokenId],msg.sender,item.tokenId);
    }

    function getTotalPrice(uint _itemId) view public returns(uint){
        return(items[_itemId].price * (100 + feePercent)/100);
    }

    function withdrawToken() public onlyOwner{

        tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));

    }

}

