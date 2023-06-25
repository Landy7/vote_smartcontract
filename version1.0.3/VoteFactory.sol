// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Proposal.sol";
import "./User.sol";
import "./Reviewer.sol";

// Proposal, User, Reviewer, Voter 相互交互的合约
contract VoteFactory {
    User[] users; // 所有用户

    //Proposal[] public publishProposals; //发布后的proposal
    Reviewer[] reviewers; // 所有审稿人
    uint256 public proposalCount;

    mapping(address => User) public addressToUser; // 地址映射到用户对象address
    //mapping(address => Voter) addressToVoter;
    mapping(address => Reviewer) public addressToReviwer; // 地址映射到Reviwer对象address

    address public chairperson;

    Reviewer technologyReviewer;
    address technology_reviewer = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    Reviewer guildmembers;
    address guild_members = 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C;


    //投票
    struct Voter{
        bool voted; //是否投过票
        address delegateAccount; //代理的地址
        bool isDelegated;
        uint256 weight;
        //根据proposalIndex来确定当前voter是赞同还是拒绝该proposal
        //1表示支持，0表示拒绝
        mapping(Proposal=>uint) proposalToRejctOrApprove; 
    }

    mapping(address => Voter) public addressToVoter; //投票


    constructor(){
        chairperson = msg.sender;
        //技术reviewer
        technologyReviewer = new Reviewer();
        //当前先改成测试账号，之后会改成真实的账号
        technologyReviewer.storeAddressAccount(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7);
        reviewers.push(technologyReviewer);
        addressToReviwer[0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7] = technologyReviewer;

        //guild members reviewer
        guildmembers = new Reviewer();
        guildmembers.storeAddressAccount(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C);
        reviewers.push(guildmembers);
        addressToReviwer[0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C] = guildmembers;

        proposalCount = 0;
    }


    // 创建一个新用户并将其添加到用户数组中
    function initialUser(address account) external {
        require(msg.sender == chairperson, "only chairperson can create the new user");
        User user = new User(); //会产生一个新的address来存放当前的user, 可以理解为使user contract 
        user.storeAddressAccount(account);
        users.push(user);
        addressToUser[account] = user; //根据address account找到对应的user
    }

    // 根据地址返回用户
    function getUserByAddress(address userAddress) external view returns (User) {
        return addressToUser[userAddress];
    }

    //根据审稿人address返回reviewer
    function getReviewerByAddress(address reviewerAddress) external view returns (Reviewer) {
        return addressToReviwer[reviewerAddress];
    }

    // //创建一个新的审稿人并将其添加到审稿人数组中---审核人员添加
    // function createNewReviewer(address account) external {
    //     require(msg.sender == chairperson, "only chairperson can create the new reviwer");
    //     Reviewer reviewer = new Reviewer();
    //     reviewer.storeAddressAccount(account);
    //     addressToReviwer[account] = reviewer;
    //     reviewers.push(reviewer);
    // }

    // 返回所有用户
    function getUsers() external view returns (User[] memory) {
        return users;
    }

    // 返回所有审稿人
    function getReviewers() external view returns (Reviewer[] memory) {
        return reviewers;
    }



    // 给与指定地址拥有”表决权“
    // 此方法只有‘chairperson’可以调用
    //之后会继续优化该方法
    function giveRightToVote(address voter) external {
        // require如果判定为false，则执行终止 && 回滚合约状态
        // 第二个参数则可以记录解释发生了什么问题（测试过 - 字符串不支持中文）
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote." // 只有主席可以赋予表决权
        );
        require(
            !addressToVoter[voter].voted,
            "The voter already voted." // 选民已经投过票
        );
        require(addressToVoter[voter].weight == 0);
        addressToVoter[voter].weight = 1;
    }

    
    // 指定to为自己的代表
    function delegate(Proposal _proposal, address to) external {
        // 从“已投票地址”voters数组 - 获取Voter选民  
        Voter storage sender = addressToVoter[msg.sender];
        require(!sender.voted, "Your already voted"); // 检查是否已参与过投票

        require(to != msg.sender, "Self-delegation is disallowed.");// 不允许指定自己为代表 

        // 一般来说使用此类循环是很危险的
        // 如果运行的时间过长，可能会需要消耗更多的gas
        // 甚至有可能会导致死循环
        // 此While是向上寻找顶层delegate（代表）
        while(addressToVoter[to].delegateAccount != address(0)) { // 地址不为空
            // 此处意思是比如有多级delegate（代表），那么就需要不断向上寻找
            to = addressToVoter[to].delegateAccount; 
            // 再向上寻找过程不允许“to”和“请求发起人”msg.sender重合
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = addressToVoter[to];

        // 检查是否又投票权
        require(delegate_.weight >= 1);
        // 更改发起人的投票状态和代理
        sender.voted = true;
        sender.delegateAccount = to;
        // 检查代理的投票状态
        // 如果已经投票则直接为提案增加投票数、反之则增加delegate_代表的投票权重
        if(delegate_.voted) {
            uint v = delegate_.proposalToRejctOrApprove[_proposal];
            if(v == 1){
                _proposal.storeApproveCount(sender.weight);
                sender.proposalToRejctOrApprove[_proposal] = 1; //1表示同意
            }else if(v == 0){
                _proposal.storeRejectCount(sender.weight);
                sender.proposalToRejctOrApprove[_proposal] = 0; //0表示不同意
            }
        } else {
            delegate_.weight += sender.weight;
        }
    }


    // 为提案投票
    function vote(Proposal _proposal, string memory ApproveOrReject) external{
        // 获取选民
        Voter storage sender = addressToVoter[msg.sender];
        // 判断是否有投票权
        require(sender.weight >= 0, "Has no rigth to vote.");
        // 判断是否已经投过票
        require(!sender.voted, "Already vote.");

        // 通过校验后，则改变其自身状态
        sender.voted = true;
        //sender.vote = proposal; ---- 之后需要存储在user的 VotedProposal中
        require(!(_proposal.getReleasedAccount() == msg.sender), "cannot_vote_the_own_proposal");
        // 为指定提案增加支持数量
        // 如果proposal超出数组范围，则会停止执行
        if(sha256(bytes(ApproveOrReject)) == sha256(bytes("yes"))){
            _proposal.storeApproveCount(sender.weight);
            sender.proposalToRejctOrApprove[_proposal] = 1; //1表示同意
        }else if(sha256(bytes(ApproveOrReject)) == sha256(bytes("no"))){
            _proposal.storeRejectCount(sender.weight);
            sender.proposalToRejctOrApprove[_proposal] = 0; //0表示不同意
        }
    }

}