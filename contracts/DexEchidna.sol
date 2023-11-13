// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Dex, SwappableToken} from "./Dex.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract DexEchidna {
    SwappableToken public token1;
    SwappableToken public token2;
    Dex dex;

    event BalanceToken1(uint256);
    event BalanceToken2(uint256);
    event SwapDex(string, uint256);

    constructor() {
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "Token One", "TKNO", 110);
        token2 = new SwappableToken(address(dex), "Token Two", "TKNT", 110);

        dex.setTokens(address(token1), address(token2));

        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        dex.renounceOwnership();
        dex.approve(address(dex), type(uint256).max);
    }

    function testSwap(bool direction, uint256 amount) public {
        uint256 balance1 = token1.balanceOf(address(this));
        uint256 balance2 = token2.balanceOf(address(this));

        if (direction) {
            uint256 swapAmount = Math.max(amount % balance2, balance2 - (amount % balance2));
            dex.swap(address(token2), address(token1), swapAmount);
        } else {
            uint256 swapAmount = Math.max(amount % balance1, balance1 - (amount % balance1));
            dex.swap(address(token1), address(token2), swapAmount);
        }

        assert(token1.balanceOf(address(dex)) == 0 || token2.balanceOf(address(dex)) == 0);
    }
}
