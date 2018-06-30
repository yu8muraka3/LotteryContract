pragma solidity ^0.4.18;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/payment/PullPayment.sol";
import "github.com/yu8muraka3/RondomNumber/RandomNumber.sol";

contract LotteryToken is ERC721Token, Ownable, RandomNumber {
    struct Lottery {
        string name;
        uint  Lotterytype;
        uint16  sold;
        uint32  readyTime;
        uint256 price;
    }

    uint ResultNumber;
    int status;
    bytes32 blockhash;
    bytes32 seed;
    uint drawnNumber;

    Lottery[] private lotteries;
    uint256 private price = 0.01 ether;
    string private name = "Lottery";
    string private symbol = "LTY";

    event RequestDrawingLots();
    event RewardHitOwner(address HitOwner, uint drawnNumber, uint256 reward, uint256 HitOwnerBalance, uint256 ContractBalance);

    function LotteryToken(uint _max) public ERC721Token(name, symbol) RandomNumber(_max){}

    // 抽選予約
    uint index = request();

    // トークン発行
    function mint(uint _index) payable public {
        require(price == msg.value);
        require(owner != address(0));

        (status, blockhash, seed, drawnNumber) = get(_index);

        require (status == 0);

        uint256 id = lotteries.push(Lottery('Lottery', drawnNumber, 0, 0, 0)) - 1;
        super._mint(msg.sender, id);

    }

    // コントラクトの残高
    function getEtherBalance() constant returns (uint256 balance) {
        balance = this.balance;
        return balance;
    }

    // トークン番号（ランダム）
    function getTokenType(uint256 _tokenid) constant returns (uint){
       Lottery token = lotteries[_tokenid];
       return token.Lotterytype;
    }

    // 抽選予約
    function requestDrawingLots() public onlyOwner() returns(uint) {
        require(owner == msg.sender);
        uint DrawingId = request();
        RequestDrawingLots();
        return DrawingId;
    }

    // 抽選結果&当選者に分配
    function rewardHitOwner(uint _DrawingId) payable public onlyOwner() returns (address HitOwner, uint drawnNumber){
        (status, blockhash, seed, drawnNumber) = get(_DrawingId);

        require(owner == msg.sender);
        uint i = 0;
        while(i < lotteries.length){
            uint Lotterytype = getTokenType(i);
            if (Lotterytype == drawnNumber){
                HitOwner = ownerOf(i);
                uint256 reward = this.balance;
                HitOwner.send(reward);
            }
            i++;
        }
        RewardHitOwner(HitOwner, drawnNumber, reward, HitOwner.balance, this.balance);

        return (HitOwner, drawnNumber);
    }

}
