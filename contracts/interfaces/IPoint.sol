// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IPoint {

	/// @notice points are given based on a specific action with a set number of points assigned when triggered
	/// @dev emitted when points are given
	event PointsGiven(address indexed to, uint256 amount, bytes32 action);

	/// @dev get total of points the user have gained
	function points(address _for) external returns(uint256);

}

interface IClaimable {

	event PointsClaimed(address indexed to, uint256 amountIn, uint256 amountOut);
	/// @dev to call when claiming claimable balance emits PointsClaimed
	function claim() external returns(bool);

	/// @dev to call when claiming claimable balance emits PointsClaimed
	function claim(uint256 amount) external returns(bool);

	/// @dev get claimable balance
	function claimable(address to) external returns(uint256);
}