// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../storages/ActionStorage.sol";
import "../interfaces/IPoint.sol";
import {AKXRoles} from "../Roles.sol";

import "./Claimable.sol";

/// @title PointyToken
/// @notice the AKX point token "PointyToken"

contract PointyToken is IPoint, ERC20("Pointy", "POINTY"), ActionStorage, Claimable, AKXRoles {

	using SafeERC20 for IERC20;

	mapping(address => uint256) public balances;
	mapping(address => uint256) public unclaimed;
	mapping(address => uint256) public claimed;

	bool public  canStartClaiming;
	uint256 public pointyForOneAKX;
	address public burnAddress;
	bool canTransfer;

	IERC20 internal akx;

	constructor(address akxToken, uint256 available, address mintTo, address burnAddr) {
		burnAddress = burnAddr;
		canTransfer = false; // this is non transferable and will never be.
		initRoles();
		akx = IERC20(akxToken);
		canStartClaiming = false;
		pointyForOneAKX = 10 * 1e18;
		setClaimableToken(address(this));
		super._mint(mintTo, available);
	}

	function claim() public override virtual returns(bool) {
		if(canStartClaiming == false) {
			revert("cannot start claiming for AKX yet");
		}

		if(claimable(_msgSender()) < balances[_msgSender()]) {
			revert("indicate the amount to claim");
		}
		uint256 currBal = balances[_msgSender()];
		claimed[_msgSender()] = currBal;
		uint256 amt = PointyForAKX(currBal);
		akx.safeTransfer(_msgSender(), amt);
		super._burn(burnAddress,claimed[_msgSender()]);
		emit PointsClaimed(_msgSender(), currBal, amt);
		return true; // stops execution to prevent reentrancy

	}
	function claim(uint256 amt) public virtual override returns(bool) {
		if(canStartClaiming == false) {
			revert("cannot start claiming for AKX yet");
		}

		if(claimable(_msgSender()) < amt) {
			revert("claiming more than available balance");
		}
		claimed[_msgSender()] = amt;
		super._burn(burnAddress,claimed[_msgSender()]);
		uint256 akxAmt = PointyForAKX(amt);
		akx.safeTransfer(_msgSender(), akxAmt); // will revert if transfers are not enabled
		emit PointsClaimed(_msgSender(), amt, akxAmt);
		return true; // stops execution to prevent reentrancy

	}

	/// @dev get claimable balance
	function claimable(address to) public view virtual override returns(uint256) {
		return unclaimed[to];
	}

	function PointyForAKX(uint256 numPointy) public view returns(uint256 totalAkx){
		totalAkx = numPointy / pointyForOneAKX;
	}

	function points(address _for) public returns(uint256) {
		return balances[_for];
	}

	function givePoints(address _to, string memory actionName) public onlyRole(AKX_OPERATOR_ROLE) {
		uint256 point = getPointsForAction(actionName);
		super._mint(_to, point);
		bytes32 actionBytes = keccak256(abi.encodePacked(actionName));
		emit PointsGiven(_to, point, actionBytes);
	}

	modifier isTransferable() {
		require(canTransfer != false || hasRole(AKX_OPERATOR_ROLE, msg.sender), "cannot trade or transfer");
		_;
	}
	function transfer(address _to, uint256 _value) public isTransferable virtual override returns (bool success) {
		if (_value > 0 && _value <= balances[msg.sender]) {
			super.transfer(_to, _value);
			success = true;
		}
		revert("cannot transfer");
	}


}