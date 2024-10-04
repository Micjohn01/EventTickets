// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

contract EventTickets {
    address public owner;
    uint public numberOfTickets;
    uint public ticketPrice;
    uint public totalAmount;
    uint public startAt;
    uint public endAt;
    uint public timeRange;
    bool public eventCancelled;
    string public message = "Welcome to the event";
    
    mapping(address => uint[]) public ticketHolders; // Track who owns which ticket

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier eventActive() {
        require(block.timestamp >= startAt && block.timestamp <= endAt, "Event is not active");
        require(!eventCancelled, "Event is cancelled");
        _;
    }

    constructor(uint _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        startAt = block.timestamp;
        endAt = block.timestamp + 7 days;
        timeRange = (endAt - startAt) / 60 / 60 / 24;
    }

    // Function to buy tickets
    function buyTicket() public payable eventActive returns (uint ticketId) {
        require(msg.value == ticketPrice, "Incorrect ticket price sent");

        numberOfTickets += 1;
        totalAmount += msg.value;
        ticketId = numberOfTickets;
        
        // Record the buyer and their ticket
        ticketHolders[msg.sender].push(ticketId);
    }

    // Function to get the total amount of tickets sold
    function getTotalAmount() public view returns (uint) {
        return totalAmount;
    }

    // Refund function (only allowed by the event owner)
    function refund(address payable _buyer, uint _ticketId) public onlyOwner {
        require(ticketHolders[_buyer].length > 0, "Buyer does not own a ticket");
        require(ticketPrice <= address(this).balance, "Insufficient balance for refund");

        // Remove the ticket from the buyer's list
        for (uint i = 0; i < ticketHolders[_buyer].length; i++) {
            if (ticketHolders[_buyer][i] == _ticketId) {
                delete ticketHolders[_buyer][i]; // Refund a specific ticket
                break;
            }
        }

        _buyer.transfer(ticketPrice); // Refund the buyer
    }

    // Function to cancel the event (only allowed by the event owner)
    function cancelEvent() public onlyOwner {
        eventCancelled = true;
    }

    // Function to withdraw funds (only allowed by the event owner)
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "No funds available to withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Function to get the tickets owned by a particular address
    function getTicketsOwned(address _holder) public view returns (uint[] memory) {
        return ticketHolders[_holder];
    }
}
