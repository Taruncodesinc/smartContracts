// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract EventTicket
{
    uint public  ticketsAvailable;
     uint public startTime=0;
     uint public  limitTicket=0;
    uint public endTIme=0;
    constructor(uint _tickets)
    {
        ticketsAvailable=_tickets;
        limitTicket=3;
        startTime=block.timestamp;
        endTIme=startTime+10000000;

    }
    mapping (address=>uint) ticketHoldBy;
    modifier ticketAvailable(uint _tickets)  
{
    require(_tickets > 0 && _tickets <= ticketsAvailable, "Not enough tickets available");
    _;
}
function getTicket(uint _tickets) public ticketAvailable(_tickets)
{
    require(_tickets<=limitTicket && block.timestamp<endTIme, "can't buy this much tickets");
    ticketHoldBy[msg.sender]+=_tickets;
    ticketsAvailable-=_tickets;
}
function sendTicket(address _sendTo, uint _ticket) public 
{
    require(ticketHoldBy[msg.sender]>=_ticket && _ticket<=limitTicket, "can't transfer");
    ticketHoldBy[msg.sender]-=_ticket;
    ticketHoldBy[_sendTo]+=_ticket;
}
function getTicketCount(address _add) public view  returns(uint)
{
    return  ticketHoldBy[_add];
}

}