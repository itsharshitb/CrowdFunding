// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{

    mapping(address=>uint) public contributors;     //map account to contributed amount
    address public manager; //organiser
    uint public minContribution;
    uint public deadline; 
    uint public target;    //target amount
    uint public raisedAmount;
    uint public noOfContributors;  // total contribtr

    constructor(uint _target, uint _deadline){  //set by the manager initially while deploying
        target=_target;
        deadline=block.timestamp+ _deadline;
        minContribution=100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline passed away!");
        require(msg.value>=minContribution,"Minimum contribution is of 100 wei!");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
}