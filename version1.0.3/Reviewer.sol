//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Proposal.sol";
import "./User.sol";

contract Reviewer is User{
    Proposal[] reviewedProposal;
    Proposal[] unreviewedProposals;
    Proposal[] rejectedProposal;

    //问题：当guildmember和technologymember的意见不一致如何决定？--需要设计
    //哪些需要设计成payable function？

    //审查proposal
    function reviewProposal(Proposal _proposal,string memory passOrNot) external returns(bool){
        bool result;
        if(sha256(bytes(passOrNot)) == sha256(bytes("pass"))){ //通过
            //第一次审查并且通过
            if(!_proposal.getIsSecondReleased()){
                _proposal.storeIsSecondReleased(true); //需要二次审查
            }else{
                //第二次审查并且通过，可以直接发布
                _proposal.storeIsApprove(true);
                _proposal.storeIsReviwed(true); //表示已审查过
                reviewedProposal.push(_proposal); //添加进入已经reviewed proposal
            }
            result = true;
        //具有一票否决权
        }else if(sha256(bytes(passOrNot)) == sha256(bytes("reject"))){ //被拒绝
            _proposal.storeIsReject(true);
            _proposal.storeIsReviwed(true); //表示已审查过
            //表示该proposal已经审查过
            for(uint i = 0; i < unreviewedProposals.length;i++){
                if(unreviewedProposals[i] == _proposal){
                    delete unreviewedProposals[i];
                }
            }
            reviewedProposal.push(_proposal);
            rejectedProposal.push(_proposal);
            result = false;
        }
        return result;
    }


    //存储新的proposal
    function storeNewProposal(Proposal _proposal) external {
        unreviewedProposals.push(_proposal); //存储需要审查的proposal
    }

    //需要先由guildMember来确定，该方案是否存在fund or technology 部分
    //没有technology部分
    function confirmProposal(Proposal _proposal,bool isFundOrNot,bool isTechnologyOrNot) external {
        //require(_proposal_index < proposals.length, "Invalid proposal index");
        require(!_proposal.getIsReviwed(), "this proposal has already reviewed!");
        _proposal.storeIsFund(isFundOrNot);
        _proposal.storeIsTechnology(isTechnologyOrNot);
    }

    // //有technology部分
    // function confirmProposalwithTechnology(Proposal _proposal,Reviewer TechnologyReviewer,bool isFundOrNot,bool isTechnologyOrNot) external {
    //     //require(_proposal_index < proposals.length, "Invalid proposal index");
    //     require(!_proposal.getIsReviwed(), "this proposal has already reviewed!");
    //     _proposal.storeIsFund(isFundOrNot);
    //     _proposal.storeIsTechnology(isTechnologyOrNot);
    //     if(isTechnologyOrNot){
    //         Reviewer(TechnologyReviewer).storeNewProposal(_proposal); //存储技术相关的proposal
    //     }
    // }

    //返回所有Unreviewed proposal address
    function getAllUnrewiewedProposal() external view returns(Proposal[] memory){
        return unreviewedProposals;
    }

    //返回所有reviewed proposal address
    function getAllRewiewedProposal() external view returns(Proposal[] memory){
        return reviewedProposal;
    }

    //返回所有rejected proposal address
    function getAllRejectedProposal() external view returns(Proposal[] memory){
        return rejectedProposal;
    }


}