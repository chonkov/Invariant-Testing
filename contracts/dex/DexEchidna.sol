// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Dex, SwappableToken} from "./Dex.sol";

contract DexEchidna {
    event Log(uint256);

    SwappableToken public token1;
    SwappableToken public token2;
    Dex dex;

    constructor() {
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "Token One", "TKNO", 110);
        token2 = new SwappableToken(address(dex), "Token Two", "TKNT", 110);

        dex.setTokens(address(token1), address(token2));

        token1.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);

        token2.approve(address(dex), 100);
        dex.addLiquidity(address(token2), 100);

        token1.approve(address(this), address(dex), type(uint256).max);
        token2.approve(address(this), address(dex), type(uint256).max);

        dex.renounceOwnership();
        dex.approve(address(dex), type(uint256).max);
    }

    function testSwap(bool direction, uint256 amount) public {
        uint256 balance1 = token1.balanceOf(address(this));
        uint256 balance2 = token2.balanceOf(address(this));

        emit Log(balance1);
        emit Log(balance2);

        uint256 balance1Dex = token1.balanceOf(address(dex));
        uint256 balance2Dex = token2.balanceOf(address(dex));

        emit Log(balance1Dex);
        emit Log(balance2Dex);

        uint256 k = token1.balanceOf(address(dex)) * token2.balanceOf(address(dex));

        emit Log(k);

        if (direction) {
            uint256 swapAmount = (amount % balance2) % balance2Dex;
            emit Log(swapAmount);
            dex.swap(address(token2), address(token1), swapAmount);
        } else {
            uint256 swapAmount = (amount % balance1) % balance1Dex;
            emit Log(swapAmount);
            dex.swap(address(token1), address(token2), swapAmount);
        }

        uint256 k2 = token1.balanceOf(address(dex)) * token2.balanceOf(address(dex));

        assert(k <= k2);
    }
}
