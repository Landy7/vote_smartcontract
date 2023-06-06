//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Proposal.sol";
import "./User.sol";

contract Reviewer is User{
    Proposal[] reviewedProposal;
    Proposal[] unreviewedProposals;

    // constructor(){
    //     accountAddressID = account;
    // }

    //审查proposal
    function reviewProposal(Proposal _proposal,string memory passOrNot) public returns(bool){
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
        }else if(sha256(bytes(passOrNot)) == sha256(bytes("reject"))){ //被拒绝
            _proposal.storeIsReject(true);
            _proposal.storeIsReviwed(true); //表示已审查过
            reviewedProposal.push(_proposal); //添加进入已经reviewed proposal
            result = false;
        }
        return result;
    }


    function storeProposal(Proposal _proposal) public {
        unreviewedProposals.push(_proposal); //存储需要审查的proposal
    }

    function viewReviewedProposal() public view returns(Proposal[] memory){
        return reviewedProposal;
    }

    //查看某个proposal
    //需要再修改一下
    function viewThisProposal(Proposal _proposal) public view returns(string memory,string memory,address){
        return (_proposal.getClassfication(), _proposal.getLongDescription(), _proposal.getReleasedAccount());
    }

}