pragma experimental ABIEncoderV2;

contract Election {
    
    struct Voter {
        bytes32 keyHash;
        bytes32 valueHash;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }
    
    string name;
    address creator;

    // Mapping from hash of voter key to bool voted
    mapping(bytes32 => bool) voted;
    // Mapping from hash of voter key to hash of voter value
    mapping(bytes32 => bytes32) validVoters;
    
    mapping(uint => Candidate) candidates;
    uint candidatesCount;
    mapping(string => bool) candidateExists;

    constructor(string memory _name, address _creator) public {
        name = _name;
        creator = _creator;
    }

    event votedEvent(uint indexed candidateId);

    function addCandidate(string memory candidateName) public {
        require(msg.sender == creator, "Only the creator can add candidates.");
        require(!candidateExists[candidateName], "Cannot add an existing candidate.");
        
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, candidateName, 0);
        candidateExists[candidateName] = true;
    }
    
    function getNumCandidates() public view
        returns (uint candidatesCount)
    {
        return candidatesCount;
    }
    
    function getCandidate(uint id) public view
        returns (Candidate memory candidate)
    {
        return candidates[id];
    }
    
    function addVoter(string memory voterKey, string memory voterValue) public {
        require(msg.sender == creator, "Only the creator can add valid voters.");
        Voter memory voter = createVoter(voterKey, voterValue);
        require(validVoters[voter.keyHash] == 0, "This voter can already vote.");
        validVoters[voter.keyHash] = voter.valueHash;
    }
    
    function createVoter(string memory voterKey, string memory voterValue) private
        returns (Voter memory voter)
    {
        bytes32 voterKeyHash = keccak256(abi.encodePacked(voterKey));
        bytes32 voterValueHash = keccak256(abi.encodePacked(voterValue));
        Voter memory voter = Voter(voterKeyHash, voterValueHash);
        return voter;
    }

    function vote(uint candidateId, string memory voterKey, string memory voterValue) public {
        Voter memory voter = createVoter(voterKey, voterValue);
        
        require(validVoters[voter.keyHash] == voter.valueHash, "Must be a valid voter.");
        require(!voted[voter.keyHash], "Cannot have already voted.");
        require((candidateId > 0) && (candidateId <= candidatesCount),
            "Must vote for valid candidate");

        voted[voter.keyHash] = true;
        candidates[candidateId].voteCount++;
        emit votedEvent(candidateId);
    }
}
