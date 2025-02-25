// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Twitter {
    // Struct to store each user's tweet information
    struct UserTweet {
        string tweetContent;
        uint256 timeStamp;
    }
    
    // Struct to store each message information
    struct Messaging {
        string messageContent;
        address sender;
        address receiver;
        uint256 sendAt;
    }
    
    // Mappings to store users' data
    mapping(address => UserTweet[]) public userAndTweetInfo;
    mapping(address => address[]) public followersOfUsers;
    mapping(address => address[]) public followingOfUsers;
    mapping(address => Messaging[]) public sendMessages;
    mapping(address => address[]) public allowedUsers;

    // Event declarations for logging actions
    event TweetPosted(address indexed user, string content, uint256 timestamp);
    event UserFollowed(address indexed follower, address indexed followed);
    event UserUnfollowed(address indexed unfollower, address indexed unfollowed);
    event MessageSent(address indexed sender, address indexed receiver, string message);
    event AccessGranted(address indexed owner, address indexed grantedUser);

    // Function to post a tweet
    function tweet(string calldata _content) external {
        userAndTweetInfo[msg.sender].push(UserTweet(_content, block.timestamp));
        emit TweetPosted(msg.sender, _content, block.timestamp);
    }

    // Function to follow a user
    function follow(address _follow) external {
        require(_follow != msg.sender, "Cannot follow oneself");
        require(!_isFollowing(msg.sender, _follow), "Already following this user");

        followersOfUsers[_follow].push(msg.sender);
        followingOfUsers[msg.sender].push(_follow);
        
        emit UserFollowed(msg.sender, _follow);
    }

    // Function to unfollow a user
    function unfollow(address _unfollow) external {
        require(_unfollow != msg.sender, "Cannot unfollow oneself");

        // Remove from followersOfUsers[_unfollow] mapping
        _removeFollower(_unfollow);

        // Remove from followingOfUsers[msg.sender] mapping
        _removeFollowing(msg.sender, _unfollow);

        emit UserUnfollowed(msg.sender, _unfollow);
    }

    // Function to send a message to a user
    function sendMessage(string calldata _msg, address _receiver) external {
        require(_receiver != msg.sender, "Cannot send message to oneself");
        sendMessages[_receiver].push(Messaging(_msg, msg.sender, _receiver, block.timestamp));
        
        emit MessageSent(msg.sender, _receiver, _msg);
    }

    // Function to retrieve the list of tweets of the sender
    function getTweets() external view returns (UserTweet[] memory) {
        return userAndTweetInfo[msg.sender];
    }

    // Function to retrieve messages received by the user
    function getMessages() external view returns (Messaging[] memory) {
        return sendMessages[msg.sender];
    }

    // Function to check if a user is following another user
    function _isFollowing(address _follower, address _followee) internal view returns (bool) {
        address[] memory followedUsers = followingOfUsers[_follower];
        for (uint256 i = 0; i < followedUsers.length; i++) {
            if (followedUsers[i] == _followee) {
                return true;
            }
        }
        return false;
    }

    // Helper function to remove a follower
    function _removeFollower(address _unfollow) internal {
        address[] storage followers = followersOfUsers[_unfollow];
        for (uint256 i = 0; i < followers.length; i++) {
            if (followers[i] == msg.sender) {
                followers[i] = followers[followers.length - 1];
                followers.pop();
                break;
            }
        }
    }

    // Helper function to remove a user from the following list
    function _removeFollowing(address _follower, address _followee) internal {
        address[] storage following = followingOfUsers[_follower];
        for (uint256 i = 0; i < following.length; i++) {
            if (following[i] == _followee) {
                following[i] = following[following.length - 1];
                following.pop();
                break;
            }
        }
    }

    // Function to grant access to a specific user (e.g., allow viewing private content)
    function grantAccess(address _grantTo) external {
        require(_grantTo != msg.sender, "Cannot grant access to oneself");
        require(!_isAllowed(msg.sender, _grantTo), "Access already granted");

        allowedUsers[msg.sender].push(_grantTo);

        emit AccessGranted(msg.sender, _grantTo);
    }

    // Function to check if access has been granted to a user
    function _isAllowed(address _owner, address _user) internal view returns (bool) {
        address[] memory allowed = allowedUsers[_owner];
        for (uint256 i = 0; i < allowed.length; i++) {
            if (allowed[i] == _user) {
                return true;
            }
        }
        return false;
    }
}
