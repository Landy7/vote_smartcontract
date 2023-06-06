// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Proposal.sol";
import "./User.sol";
import "./Reviewer.sol";

// Proposal, User, Reviewer, Voter 相互交互的合约
contract VoteFactory {
    User[] users; // 所有用户
    Proposal[] proposals; // 所有提案（包括未发布的、发布的和审核的）,该array里面的proposal不能删掉，与id有关
    Proposal[] unreviewedProposals; //所有新发布的proposal, 未被审核过的
    Proposal[] reviewedProposals; //所有被审核过的proposal
    Proposal[] ApprovedProposals; //所有审核通过的proposal
    Proposal[] RejectProposals; // 所有被拒绝通过的proposal
    Proposal[] secondReviewedProposals; //二次审核的proposal

    //Proposal[] fundProposals; //之后再分类
    //Proposal[] technologyProposals; //之后再分类

    Proposal[] publishProposals; //发布后的proposal
    Reviewer[] reviewers; // 所有审稿人
    uint256 proposalCount;
    uint256 proposal_index;

    mapping(address => User) addressToUser; // 地址映射到用户
    //mapping(address => Voter) addressToVoter;
    mapping(address => Reviewer) addressToReviwer;

    address public chairperson;

    Reviewer technologyReviewer;
    Reviewer guildmembers;

    constructor(){
        chairperson = msg.sender;
        //技术reviewer
        technologyReviewer = new Reviewer();
        technologyReviewer.storeAddressAccount(0x060848d7a790ac7302b122a7Ba843CFA72829458);
        reviewers.push(technologyReviewer);
        addressToReviwer[0x060848d7a790ac7302b122a7Ba843CFA72829458] = technologyReviewer;

        //guild members reviewer
        guildmembers = new Reviewer();
        guildmembers.storeAddressAccount(0x060848d7a790ac7302b122a7Ba843CFA72829458);
        reviewers.push(guildmembers);
        addressToReviwer[0x060848d7a790ac7302b122a7Ba843CFA72829458] = guildmembers;

        proposalCount = 0;
        proposal_index = 0;
    }


    // 创建一个新用户并将其添加到用户数组中
    function initialUser(address account) public {
        require(msg.sender == chairperson, "only chairperson can create the new user");
        User user = new User();
        user.storeAddressAccount(account);
        users.push(user);
        addressToUser[account] = user; //根据address account找到对应的user
    }

    // 创建一个新提案并将其添加到提案数组中
    function writeNewProposal(string memory _title, 
                            string memory _short_description, 
                            string memory _classification,
                            address[] memory _teamMemberAccount,
                            string[] memory _teamMembersResponsibilities,
                            address _userAccount) public {
        User user = addressToUser[_userAccount]; //找到对应的user
        //创建新proposal
        Proposal proposal = user.writeNewProposal(proposal_index,
                                                _title,
                                                _short_description,
                                                _classification,
                                                _teamMemberAccount,
                                                _teamMembersResponsibilities,
                                                _userAccount);
        proposals.push(proposal); //添加新的proposal到这里
        unreviewedProposals.push(proposal); //所有新发布的proposal
        proposal_index++; //索引+1
        proposalCount++; //count+1

    }

    // 根据地址返回用户
    function getUserByAddress(address userAddress) public view returns (User) {
        return addressToUser[userAddress];
    }

    // 创建一个新的审稿人并将其添加到审稿人数组中
    function createNewReviewer(address account) public {
        require(msg.sender == chairperson, "only chairperson can create the new reviwer");
        Reviewer reviewer = new Reviewer();
        reviewer.storeAddressAccount(account);
        addressToReviwer[account] = reviewer;
        reviewers.push(reviewer);
    }

    // 返回所有用户
    function getUsers() public view returns (User[] memory) {
        return users;
    }

    // 返回所有提案
    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }


    //需要先由guildMember来确定，该方案是否存在fund or technology 部分
    function confirmProposalFundAndTechnology(uint _proposal_index,bool isFundOrNot,bool isTechnologyOrNot) public {
        require(_proposal_index < proposals.length, "Invalid proposal index");
        require(msg.sender == guildmembers.getAddressAccount(), 
        "you are not allowed to review the proposal!");
        Proposal proposal = proposals[_proposal_index];
        require(!proposal.getIsReviwed(), "this proposal has already reviewed!");
        proposal.storeIsFund(isFundOrNot);
        proposal.storeIsTechnology(isTechnologyOrNot);
        if(isTechnologyOrNot){
            technologyReviewer.storeProposal(proposal); //存储技术相关的proposal
        }
        guildmembers.storeProposal(proposal); //存储该proposal;
    }


    //该proposal是通过还是驳回
    //only reviewer can call this function
    function reviewProposal(uint _proposal_index, string memory PassOrNot) public returns(bool){
        require(_proposal_index < proposals.length, "Invalid proposal index");
        Proposal proposal = proposals[_proposal_index];
        bool flag = false;
        for(uint i = 0; i < reviewers.length; i++){
            User user = reviewers[i];
            if(user.getAddressAccount() == msg.sender){
                flag = true;
                break;
            }
        }
        require(flag, "only reviewer can call this function");
        require(!proposal.getIsReviwed(), "this proposal has already reviewed!");
        //bool wholeResult = false;
        bool result1;
        bool result2;
        if(proposal.getIsTechnology()){
            result1 = technologyReviewer.reviewProposal(proposal,PassOrNot);
        }
        result2 = guildmembers.reviewProposal(proposal,PassOrNot);

        //该方案被驳回
        if(proposal.getIsReject()){
            RejectProposals.push(proposal);
            reviewedProposals.push(proposal);
            delete unreviewedProposals[_proposal_index];
        }

        if(proposal.getIsSecondReleased()){
            //第二次审核
            if(proposal.getIsApprove()){
                ApprovedProposals.push(proposal);
                reviewedProposals.push(proposal);
            }
            reviewedProposals.push(proposal);
            delete unreviewedProposals[_proposal_index];
        }else{
            //第一次审核
            proposal.storeIsSecondReleased(true); //说明该Proposal还需要修改
        }

        if(proposal.getIsTechnology()){
            if((result1 && result2) == true){
                return true;
            }else{
                return false;
            }
        }else{
            if(result2){
                return true;
            }else{
                return false;
            }
        }

    }

    // 返回所有审稿人
    function getReviewers() public view returns (Reviewer[] memory) {
        return reviewers;
    }

    //发表proposal ---用户来发表proposal
    //需要设置开始投票时间以及结束投票时间
    function publishProposal(uint _proposal_index, uint day) public{
        Proposal proposal = proposals[_proposal_index];
        require(proposal.getIsApprove(),"only approved proposal can be published!");
        User user = addressToUser[msg.sender];
        require(proposal.getReleasedAccount() == user.getAddressAccount(), "Only the proposal owner can publish the proposal");
        user.setPublishProposalTime(proposal,day); //设置投票时间
        publishProposals.push(proposal); //发布后的proposal
    }

 
    // 投票人员为提案投票
    function voteForProposal(uint _proposal_index) public {
        require(_proposal_index < proposals.length, "Invalid proposal index");
        Proposal proposal = proposals[_proposal_index];
        User user = addressToUser[msg.sender];
        require(!(proposal.getReleasedAccount() == user.getAddressAccount()), "cannot vote the own proposal");
        user.vote(proposal);
    }

    //代理
    function delegateForProposal(address to, uint _proposal_index) public{
        require(_proposal_index < proposals.length, "Invalid proposal index");
        Proposal proposal = proposals[_proposal_index];
        User user = addressToUser[msg.sender];
        user.delegate(to,proposal);
    }

}