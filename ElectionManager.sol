pragma experimental ABIEncoderV2;

import './Election.sol';

contract ElectionManager {

    mapping(string => Election) private elections;
    mapping(string => bool) private electionExists;
    string[] private electionNames;
    

    constructor() public {
    }

    function createElection(string memory name) public {
        require(electionExists[name] == false, "Cannot reuse election name");
        
        Election newElection = new Election(name, msg.sender);
        elections[name] = newElection;
        electionNames.push(name);
        electionExists[name] = true;
    }
    
    function getElectionNames() public view
        returns (string[] memory names)
    {
        return electionNames;
    }
    
    function getElection(string memory name) public view
        returns (Election election)
    {
        return elections[name];
    }
}
