// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console2 } from "forge-std/Test.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract MyFirstPythContract {

//    export ETH_USD_ID=0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace
//    export PYTH_ARB_SEPOLIA_ADDRESS=0x4374e5a8b9C22271E9EB878A2AA31DE97DF15DAF
    IPyth pyth;
    bytes32 ethUsdPriceId;

    constructor(address _pyth, bytes32 _ethUsdPriceId) {
        pyth = IPyth(_pyth);
        ethUsdPriceId = _ethUsdPriceId;
    }

    function mint() public payable {
        PythStructs.Price memory price = pyth.getPrice(ethUsdPriceId);
        console2.log("price of ETH in USD");
        console2.log(price.price);

        uint ethPrice18Decimals = (uint(uint64(price.price)) * (10 ** 18)) /
            (10 ** uint8(uint32(-1 * price.expo)));
        uint oneDollarInWei = ((10 ** 18) * (10 ** 18)) / ethPrice18Decimals;

        console2.log("required payment in wei");
        console2.log(oneDollarInWei);

        if (msg.value >= oneDollarInWei) {
            // User paid enough money.
            // TODO: mint the NFT here
        } else {
            revert InsufficientFee();
        }
    }

    function updateAndMint(bytes[] calldata pythPriceUpdate) external payable {
        uint updateFee = pyth.getUpdateFee(pythPriceUpdate);
        pyth.updatePriceFeeds{ value: updateFee }(pythPriceUpdate);

        mint();
    }

    // Error raised if the payment is not sufficient
    error InsufficientFee();
}
