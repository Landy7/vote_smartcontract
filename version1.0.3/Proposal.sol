//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Proposal{

    string title; //标题
    string classification; //类型（当前规划了8种类型）
    string short_description; // 短描述
    string long_description; //长描述 （在正式发表前需要填写）
    uint256 timestamp; //产生提案的时间节点
    address[] teamMemberAccount; //用于之后奖励
    address releasedAccount; //谁提交的就记录谁的account
    bool isReleased; //是否是发表状态
    bool isReviewed; //是否是reviewed状态
    bool isReject; //提案被驳回
    bool isApprove; //提案通过，可以发表
    bool isSecondReleased; //二次发布(用于即将发表给公众)
    bool isPublic;
    bool isOver; //提案过期
    bool isTechnology; //是否是与技术相关
    bool isFund; //是否需要资金支持
    uint256 voteApprove; //多少投票人员赞成
    uint256 voteReject; //多少用户拒绝
    uint startTime; //投票开始时间
    uint endTime; //投票结束时间
    uint voteCount;

    //初始化
    constructor(){
        isReleased = false;
        isReviewed = false;
        isPublic = false;
        isOver = false;
        isTechnology = false;
        isFund = false;
        isReject = false; //提案被驳回
        isApprove = false; //提案通过，可以发表
        isSecondReleased = false; //二次发布(用于即将发表给公众)
        voteApprove = 0;
        voteReject = 0;
        voteCount = 0;
    }

    function storeTitle(string memory _title) external {
        title = _title;
    }
    
    function getTitle() external view returns(string memory){
        return title;
    }

    function storeClassfication(string memory _classification) external{
        classification = _classification;
    }

    function getClassfication() external view returns(string memory){
        return classification;
    }

    function storeShortDescription(string memory _short_description) external{
        short_description = _short_description;
    }

    function getShortDescription() external view returns(string memory){
        return short_description;
    }

    function storeLongDescription(string memory _long_description) external{
        long_description = _long_description;
    }

    function getLongDescription() external view returns(string memory){
        return long_description;
    }

    function storeTimeStamp(uint256 _timestamp) external{
        timestamp = _timestamp;
    }

    function getTimeStamp() external view returns(uint256){
        return timestamp;
    }

    //获取团队的accounts
    function storeTeamMembersAccount(address[] memory _teamMemberAccount) external {
        teamMemberAccount = _teamMemberAccount;
    }

    //返回团队的account
    function getTeamMemberAccount() external view returns(address[] memory){
        return teamMemberAccount;
    }

    //获取发布proposal的account
    function storeReleasedAccount(address _releasedAccount) external{
        releasedAccount = _releasedAccount;
    }

    //返回发布proposal的account
    function getReleasedAccount() external view returns(address){
        return releasedAccount;
    }

    function storeIsReleased(bool _isReleased) external {
        isReleased = _isReleased;
    }

    function getIsReleased() external view returns(bool){
        return isReleased;
    }

    function storeIsReviwed(bool _isReviwed) external {
        isReviewed = _isReviwed;
    }

    function getIsReviwed() external view returns(bool){
        return isReviewed;
    }

    function storeIsFund(bool _isFund) external {
        isFund = _isFund;
    }

    function getIsFund() external view returns(bool){
        return isFund;
    }

    function storeIsSecondReleased(bool _isSecondReleased) external {
        isSecondReleased = _isSecondReleased;
    } 

    function getIsSecondReleased() external view returns(bool){
        return isSecondReleased;
    }

    function storeIsTechnology(bool _isTechnology) external {
        isTechnology = _isTechnology;
    } 

    function getIsTechnology() external view returns(bool){
        return isTechnology;
    }

    function storeIsApprove(bool _isApprove) external {
        isApprove = _isApprove;
    } 

    function getIsApprove() external view returns(bool){
        return isApprove;
    }

    function storeIsPublic(bool _isPublic) external {
        isPublic = _isPublic;
    } 

    function getIsPublic() external view returns(bool){
        return isPublic;
    }

    function storeIsReject(bool _isReject) external {
        isReject = _isReject;
    } 

    function getIsReject() external view returns(bool){
        return isReject;
    }

    function storeStartTime(uint _startTime) external {
        startTime = _startTime;
    }

    function getStartTime() external view returns(uint){
        return startTime;
    }

    function storeEndTime(uint _endTime) external {
        endTime = _endTime;
    }

    function getEndTime() external view returns(uint){
        return endTime;
    }

    function storeApproveCount(uint _voteApprove) external {
        voteApprove += _voteApprove;
    }

    function getApproveCount() external view returns(uint){
        return voteApprove;
    }

    function storeRejectCount(uint _voteReject) external {
        voteReject += _voteReject;
    }

    function getRejectCount() external view returns(uint){
        return voteReject;
    }


}