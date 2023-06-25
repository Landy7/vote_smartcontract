//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Proposal.sol";
import "./Reviewer.sol";

contract User{

    string[] classification;

    string class1 = "governance_structure";
    string class2 = "promotion & rep_score";
    string class3 = "voting";
    string class4 = "salary system";
    string class5 = "community";
    string class6 = "tokenomics system";
    string class7 = "carbon reduction system";
    string class8 = "UI/UX design";


    address accountAddress;
    uint256 reputation_score; //如何去中心化？
    Proposal[] publicProposal; //已经发布过的proposal
    //string[] publicProposalOfString;
    Proposal[] voteProposals; //投过票的proposal
    Proposal[] releasedProposal; //提交过的Proposal
    Proposal[] theRejectedProposal; //拒绝过的Proposal
    mapping(address => Reviewer) addressToReviwer; // 地址映射到Reviwer对象address
    // address technologyReviewer = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    // address guildMembers = 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C;


    //mapping(address => Voter) voters; //根据address来获得Voter的信息
    //uint256 weight;
    //bool voted; //是否投过票
    // address delegateAccount; //代理的地址
    // bool isDelegated;

    //mapping(address => Proposal[]) getUserReleasedProposals; //查看当前用户发表过的proposal
    //address public immutable chairperson;

    constructor(){
        //accountAddressID = account;
        reputation_score = 0;
        classification.push(class1);
        classification.push(class2);
        classification.push(class3);
        classification.push(class4);
        classification.push(class5);
        classification.push(class6);
        classification.push(class7);
        classification.push(class8);

    }

    function storeAddressAccount(address account) external {
        accountAddress = account;
    }

    function getAddressAccount() external view returns(address){
        return accountAddress;
    }

    //user写新的proposals
    //teamwork写proposal应该怎么设计？
    function writeNewProposal(string memory _title, 
                                string memory _short_description,
                                uint256 _classification,
                                Reviewer guildMembers) external returns(Proposal){
        Proposal proposal = new Proposal(); //实例化一个proposal
        proposal.storeTitle(_title); //输入title
        proposal.storeShortDescription(_short_description);//输入short_description
        proposal.storeClassfication(classification[_classification]); //输入classification
        //判断teamAccount是否为空
        // if(_teamMemberAccount[0] != address(0)){
        //     proposal.storeTeamMembersAccount(_teamMemberAccount);
        // }
        proposal.storeReleasedAccount(accountAddress); //存储发表的account
        proposal.storeIsReleased(true); //存储为true,不能直接proposal.isRelease = true 赋值
        releasedProposal.push(proposal);//添加自己编写的proposals
        // if(isTechnologyOrNot){
        //     Reviewer(addressToReviwer[technologyReviewer]).storeNewProposal(proposal);
        // }else{
        //     Reviewer(addressToReviwer[guildMembers]).storeNewProposal(proposal);
        // }
        //给到guildMember新设计的提案
        Reviewer(guildMembers).storeNewProposal(proposal);
        return proposal;
    }



    //proposal准备即将发布，返回给用户再次修改proposal的机会
    function modifyTheProposal(Proposal _proposal,
                                string memory _title,
                                string memory _short_description,
                                uint256 _classification,
                                string memory _long_description
                                ) external returns(Proposal){

        //可以第二次发布并且是未审核状态
        require(_proposal.getReleasedAccount() == accountAddress, "only owner can modify the proposal!");
        require((_proposal.getIsSecondReleased() && !_proposal.getIsReviwed()), "you cannot modify this proposal!");  
        _proposal.storeTitle(_title);
        _proposal.storeClassfication(classification[_classification]);
        _proposal.storeShortDescription(_short_description);
        _proposal.storeLongDescription(_long_description); 

        //判断teamAccount是否为空
        // if(_teamMemberAccount[0] != address(0)){
        //     _proposal.storeTeamMembersAccount(_teamMemberAccount);
        // }

        _proposal.storeReleasedAccount(accountAddress); //存储发表的account   
        return _proposal;                          
    }

    function deleteProposal(Proposal _proposal) view external {
        require(_proposal.getReleasedAccount() == accountAddress, "only owner can delete the proposal!");
        delete _proposal;
    }


    //获得所有编写的Proposal的地址
    function getProposals() external view returns (Proposal[] memory){
        return releasedProposal;
    }

    //查看全部发布了的proposal
    function viewPublicProposal() external view returns (Proposal[] memory){
        return publicProposal;
    }

    //发表proposal ---用户来发表proposal
    //设置发表方案的时间
    function setPublishProposalTime(Proposal _proposal,uint day) external{
        require(_proposal.getReleasedAccount() == accountAddress, "only owner can publish the proposal!");
        require(_proposal.getIsApprove(),"Only approved proposal can be published!");
        uint currentTime = block.timestamp;
        _proposal.storeStartTime(currentTime);
        _proposal.storeEndTime(currentTime + day);
        publicProposal.push(_proposal); //发布后的proposal
        _proposal.storeIsPublic(true); //可以发表状态
    }


    // function storeDelegateAddressAccount(address account) external {
    //     delegateAccount = account;
    // }

    // function getDelegateAddressAccount() external view returns(address){
    //     return delegateAccount;
    // }

    // function storeVoted(bool voted_) external {
    //     voted = voted_;
    // }

    // function getVoted() external view returns(bool){
    //     return voted;
    // }

    // function storeWeight(uint weight_) external {
    //     weight += weight_;
    // }

    // function getWeight() external view returns(uint){
    //     return weight;
    // }



    // // 指定to为自己的代表
    // function delegate(User sender, User delegatePerson, Proposal _proposal) external {
    //     // 从“已投票地址”voters数组 - 获取Voter选民  
    //     //User storage sender = voters[msg.sender];
    //     require(!delegatePerson.getVoted(), "Your already voted"); // 检查是否已参与过投票

    //     require(delegatePerson.getAddressAccount() != msg.sender, "Self-delegation is disallowed.");// 不允许指定自己为代表 

    //     address to = delegatePerson.getDelegateAddressAccount();

    //     // 一般来说使用此类循环是很危险的
    //     // 如果运行的时间过长，可能会需要消耗更多的gas
    //     // 甚至有可能会导致死循环
    //     // 此While是向上寻找顶层delegate（代表）
    //     while(to != address(0)) { // 地址不为空
    //         // 此处意思是比如有多级delegate（代表），那么就需要不断向上寻找
    //         to = delegatePerson.getDelegateAddressAccount(); 
    //         // 再向上寻找过程不允许“to”和“请求发起人”msg.sender重合
    //         require(to != msg.sender, "Found loop in delegation.");
    //     }

    //     User delegate_ = delegatePerson;

    //     // 检查是否又投票权
    //     require(delegate_.getWeight() >= 1);
    //     // 更改发起人的投票状态和代理
    //     sender.storeVoted(true);
    //     sender.storeDelegateAddressAccount(delegate_.getAddressAccount());
    //     // 检查代理的投票状态
    //     // 如果已经投票则直接为提案增加投票数、反之则增加delegate_代表的投票权重

    //     if(delegate_.getVoted()) {
    //         _proposal.storeVoteCount(sender.getWeight());
    //     } else {
    //         delegate_.storeWeight(sender.getWeight());
    //     }
    // }



    // // 为提案投票
    // //还有一些问题，该function
    // function vote(User sender, Proposal _proposal) external {
    //     // 判断是否有投票权
    //     require(sender.getWeight() >= 0, "Has no rigth to vote.");
    //     // 判断是否已经投过票
    //     require(!sender.getVoted(), "Already vote.");

    //     // 通过校验后，则改变其自身状态
    //     sender.storeVoted(true);
    //     voteProposals.push(_proposal);

    //     // 为指定提案增加支持数量
    //     // 如果proposal超出数组范围，则会停止执行
    //     _proposal.storeVoteCount(sender.getWeight());
    // }


}