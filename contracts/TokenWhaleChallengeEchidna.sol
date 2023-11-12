// SPDX-License Identifier:MIT
pragma solidity 0.7.0;

import "./TokenWhaleChallenge.sol";

contract TokenWhaleChallengeEchidna is TokenWhaleChallenge {
    TokenWhaleChallenge public token;

    constructor() TokenWhaleChallenge(msg.sender) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }
}
