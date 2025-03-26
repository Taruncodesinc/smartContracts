// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EthTransfer {
    // Event to emit when a transfer occurs
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Received(address indexed sender, uint256 amount);

    // Payable constructor to accept ETH on deployment
    constructor() payable {}

    // Function to transfer ETH to another address from contract balance
    function transferEth(address payable _to, uint256 _amount) public {
        _amount=_amount*1e18; // converting gwei to eth
        require(_to != address(0), "Invalid recipient address");
        require(_amount > 0, "Must send some ETH");
        require(_amount <= address(this).balance, "Insufficient contract balance");

        // Transfer ETH from contract balance
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send ETH");

        // Emit transfer event
        emit Transfer(address(this), _to, _amount);
    }

    // Function to deposit ETH into the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");
        emit Received(msg.sender, msg.value);
    }

    // Function to get contract balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to get address balance
    function getAddressBalance(address _address) public view returns (uint256) {
        return _address.balance;
    }

    // Special function to receive ETH
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Fallback function in case someone sends ETH with data
    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }
}
