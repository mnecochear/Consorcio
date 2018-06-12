pragma solidity ^0.4.4;

contract Consorcio {
    mapping (address => uint) public memberId;
    Member[] public members;

    event MembershipChanged(address member, bool isMember);

    struct Member {
        address member;
        string name;
        uint memberSince;
    }

    // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyMembers {
        require(memberId[msg.sender] != 0);
        _;
    }

    constructor() public {
        // It’s necessary to add an empty first member
        addMember(0, "");
    }

    function addMember(address targetMember, string memberName) public {
        uint id = memberId[targetMember];
        if (id == 0) {
            memberId[targetMember] = members.length;
            id = members.length++;
        }

        members[id] = Member({member: targetMember, memberSince: now, name: memberName});
        emit MembershipChanged(targetMember, true);
    }

    function removeMember(address targetMember) public {
      require(memberId[targetMember] != 0);

      for (uint i = memberId[targetMember]; i<members.length-1; i++){
          members[i] = members[i+1];
      }
      delete members[members.length-1];
      members.length--;
    }

    function getMembers() public view returns (bytes32[10]) {
      bytes32[10] memory names;
      for (uint i = 0; i < members.length; i++) {
        names[i] = stringToBytes32(members[i].name);
      }
      return names;
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
        return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
    }
}
