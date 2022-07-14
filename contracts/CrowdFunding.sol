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

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;  //keep track of voters for yes/no        
    }
    mapping(uint=>Request) requests;    //map each request with int
    uint public numRequests; //count total request made

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

    function refund() public{
        require(block.timestamp>deadline && target>raisedAmount,"You are not eligible for refund");
        require(contributors[msg.sender]>0,"You haven't contributed yet");
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }

    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    } 

    function voteRequest(uint _reqno) public{
        require(contributors[msg.sender]>0,"You must be contributor in order to vote");
        Request storage thisRequest = requests[_reqno];
        require(thisRequest.voters[msg.sender]==false,"You have already voted!");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++; 
    }
}