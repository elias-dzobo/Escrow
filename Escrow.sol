// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Escrow {
    address payable public buyer;
    address payable public seller;
    address public arbiter;
    uint public totalAmount;

    enum State {Created, Locked, Released, Inactive}
    State public currentState; 


    constructor(address payable _buyer, address payable _seller, address _arbiter) {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
        totalAmount = 0;
        currentState = State.Created;
    }
 
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only the arbiter can call this function.");
        _;
    }

    modifier inState(State _state) {
        require(currentState == _state, "Invalid state for this operation.");
        _;
    }

    event FundsDeposited(uint256 amount);
    event ApprovedByArbiter();
    event ReleasedToSeller();
    event RefundedToBuyer();


    function deposit() external payable onlyBuyer inState(State.Created) {
        require(msg.value > 0, "Amount must be greater than 0");
        totalAmount += msg.value; 
        currentState = State.Locked;
        emit FundsDeposited(msg.value);
    }

    function approveByArbiter() external onlyArbiter inState(State.Locked) {
        currentState = State.Released;
        emit ApprovedByArbiter();
    }

    function releaseToSeller() external onlySeller inState(State.Released) {
        seller.transfer(totalAmount);
        currentState = State.Inactive;
        emit ReleasedToSeller();
    }

    function refundToBuyer() external onlySeller inState(State.Locked) {
        buyer.transfer(totalAmount);
        currentState = State.Inactive;
        emit RefundedToBuyer();
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }


}