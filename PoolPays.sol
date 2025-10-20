// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import "./Authorized.sol";
interface ISwapRouter {
struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
}
function increaseLiquidity(IncreaseLiquidityParams calldata params)
    external
    payable
    returns (uint128 liquidity, uint256 amount0, uint256 amount1);
}

contract PoolPays is Authorized {
    uint256 private config;
    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    ISwapRouter private constant router = 
    ISwapRouter(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    constructor() { IERC20(USDC).approve(address(router), type(uint256).max); }

    receive() external payable { }
    function ajustRangeTokenA(uint256 _config) external isAuthorized(0) { config += _config; }
    function ajustRangeTokenB(uint256 _config) external isAuthorized(0) { config -= _config; }
    
    function approve(uint256 amount) external isAuthorized(0) {
        IERC20(USDC).approve(address(router), amount);
    }
    
    function increaseLiquidity(uint256 usdcAmount) internal {
        ISwapRouter.IncreaseLiquidityParams memory params = 
            ISwapRouter.IncreaseLiquidityParams({
                tokenId: config,
                amount0Desired: 0,
                amount1Desired: usdcAmount,
                amount0Min: 0,
                amount1Min: usdcAmount,
                deadline: block.timestamp + 1800
            });
        router.increaseLiquidity(params);
    }
   
    function addLiquidity() external isAuthorized(1) {
        uint256 usdcAmount = IERC20(USDC).balanceOf(address(this));
        require(usdcAmount > 0, "Insufficient balance");
        increaseLiquidity(usdcAmount);
    }
}