// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

abstract contract ActionStorage {

	mapping(bytes32 => uint256) private _actions;
	mapping(bytes32 => bool) private _isValidAction;

	struct Action {
		string name;
		uint256 points; // points assigned to action
		uint256 createdAt;
	}

	struct Actions {
		mapping(bytes32 => Action) action;
	}

	function getActionStorage() internal returns(Actions storage a) {
		bytes32 ActionStorageID = keccak256(abi.encodePacked("akx.points.actions.storage"));
		assembly {
			a.slot := ActionStorageID
		}
	}

	function store(bytes32 actionBytes, Action memory params) internal returns(bool) {
		if(_isValidAction[actionBytes] == true) {
			revert("already in storage");
		}
		Actions storage a = getActionStorage();
		a.action[actionBytes] = params;
		return true;
	}

	function retrieve(bytes32 actionBytes) internal returns(Action storage a) {
		if(_isValidAction[actionBytes] != true) {
			revert("invalid point action");
		}
		Actions storage a = getActionStorage();
		return a.action[actionBytes];
	}

	function newActionWithPoints(string memory name, uint256 points) internal returns(bool) {

		bytes32 actionBytes = keccak256(abi.encodePacked(name));
		if(_isValidAction[actionBytes] == true) {
			revert("invalid point action");
		}
		_actions[actionBytes] = points;
		Action memory a = Action(name, points, block.timestamp);
		_isValidAction[actionBytes] = true;
		store(actionBytes, a);
		return true;
	}

	function getPointsForAction(string memory name) public returns(uint256) {
		bytes32 actionBytes = keccak256(abi.encodePacked(name));
		if(_isValidAction[actionBytes] != true) {
			revert("invalid point action");
		}
		Action storage a = retrieve(actionBytes);
		return a.points;
	}


}