// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./BondingCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract BondingCurveEchidna {
    BondingCurveSale bondingCurve;

    event BalanceToken1(uint256);
    event BalanceToken2(uint256);
    event SwapDex(string, uint256);

    constructor() {
        bondingCurve = new BondingCurveSale("Bonding Curve Token", "BCT");
    }

    function test_buy_should_be_sucessful(uint256 _amount) public {
        uint256 amount = _amount == 0 ? 1 ether : _amount;

        uint256 startingBalance = bondingCurve.balanceOf(address(this));
        uint256 startingEtherBalance = address(this).balance;
        uint256 startingContractEtherBalance = address(bondingCurve).balance;

        uint256 purchaseCost = bondingCurve.buyPriceCalculation(amount);
        bondingCurve.buy{value: purchaseCost}(amount);

        assert(bondingCurve.balanceOf(address(this)) == startingBalance + amount);
        assert(address(this).balance == startingEtherBalance - purchaseCost);
        assert(address(bondingCurve).balance == startingContractEtherBalance + purchaseCost);
    }

    function test_after_buy_price_increase(uint256 _amount) public {
        uint256 amount = _amount < 10 ** bondingCurve.decimals() ? 1 ether : _amount;

        uint256 startPurchaseCost = bondingCurve.buyPriceCalculation(amount);

        test_buy_should_be_sucessful(amount);

        uint256 endPurchaseCost = bondingCurve.buyPriceCalculation(amount);

        assert(endPurchaseCost > startPurchaseCost);
    }

    function test_sell_is_executed_if_tokens_are_sent_to_BondingCurve(uint256 amount) public {
        test_buy_should_be_sucessful(amount);

        uint256 startingTokenBalance = bondingCurve.balanceOf(address(this));
        uint256 startingEtherBalance = address(this).balance;
        uint256 startingContractEtherBalance = address(bondingCurve).balance;
        uint256 returnedFunds = bondingCurve.sellPriceCalculation(amount);

        bondingCurve.transferFromAndCall(address(this), address(bondingCurve), amount);

        assert(bondingCurve.balanceOf(address(this)) == startingTokenBalance - amount);
        assert(address(this).balance == startingEtherBalance + returnedFunds);
        assert(address(bondingCurve).balance == startingContractEtherBalance - returnedFunds);
    }

    function test_sell_is_executed_successfuly(uint256 amount) public {
        test_buy_should_be_sucessful(amount);

        uint256 startingTokenBalance = bondingCurve.balanceOf(address(this));
        uint256 startingEtherBalance = address(this).balance;
        uint256 startingContractEtherBalance = address(bondingCurve).balance;
        uint256 purchaseCost = bondingCurve.sellPriceCalculation(amount);

        bondingCurve.onTransferReceived(address(this), address(this), amount, bytes(""));

        assert(bondingCurve.balanceOf(address(this)) == startingTokenBalance - amount);
        assert(address(this).balance == startingEtherBalance + purchaseCost);
        assert(address(bondingCurve).balance == startingContractEtherBalance - purchaseCost);
    }

    function test_after_sell_price_decrease(uint256 _amount) public {
        uint256 amount = _amount < 10 ** bondingCurve.decimals() ? 1 ether : _amount;

        test_buy_should_be_sucessful(amount);
        uint256 startPurchaseCost = bondingCurve.currentPrice();

        test_sell_is_executed_successfuly(amount);

        uint256 endPurchaseCost = bondingCurve.currentPrice();

        assert(endPurchaseCost < startPurchaseCost);
    }
}
