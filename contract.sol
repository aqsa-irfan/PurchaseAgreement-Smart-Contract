//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;
contract purchaseAgreement{
    uint256 public value;
    address payable public seller;
    address payable public buyer;

    enum State{Created , Locked , Released , Inactive}
    State public state;
    constructor() payable
    {
        seller=payable(msg.sender);
        value=msg.value/2;
    }
    modifier inState(State _state)
    {
        if(state!=_state){
            revert("Invalid state");
        }
        _;
    }
    modifier onlyBuyer(){
        if(msg.sender!=buyer)
        {
            revert("Only buyer can call this function");
        }
        _;
    }
    modifier onlySeller(){
        if(msg.sender!=seller)
        {
            revert("Only seller can call this function");
        }
        _;
    }
    function confirmPurchase() external inState(State.Created) payable{
        require(msg.value==(2*value),"please send in the 2x of purchase amount");
        buyer=payable(msg.sender);
        state=State.Locked;
    }
    function confirmRecieved() external onlyBuyer inState(State.Locked){
        state=State.Released;
        buyer.transfer(value);
    }
    function paySeller() external onlySeller inState(State.Released)
    {
        state=State.Inactive;
        seller.transfer(3*value);
    }
    function abort() external onlySeller inState(State.Created)
    {
        state=State.Inactive;
        seller.transfer(address(this).balance);
    }
}
