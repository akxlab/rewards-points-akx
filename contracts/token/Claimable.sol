// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import {IClaimable} from "../interfaces/IPoint.sol";

abstract contract Claimable is IClaimable {

	address private _claimableToken;


	function setClaimableToken(address _token) internal {
		_claimableToken = _token;
	}

	function claim() public virtual override returns(bool);
	function claim(uint256 amount) public virtual override returns(bool);

	/// @dev get claimable balance
	function claimable(address _to) public view virtual returns(uint256);
}