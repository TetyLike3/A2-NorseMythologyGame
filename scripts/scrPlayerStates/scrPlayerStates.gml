enum PlayerStates {
	IDLE, MOVE, JUMP, ATTACK, STUN, BLOCK
}

function HandlePlayerState() {
	lastState = currentState;
	ySpeed += playerGravity;
	executeGroundCollision();
	switch currentState {
		case PlayerStates.IDLE:
			if (INPUT_LEFT or INPUT_RIGHT) {
				currentState = PlayerStates.MOVE;
				return;
			}
			if (INPUT_JUMP) {
				currentState = PlayerStates.JUMP;
				return;
			}
			return;
		break;
		case PlayerStates.MOVE:
			if (not (INPUT_LEFT or INPUT_RIGHT)) {
				currentState = PlayerStates.IDLE;
				return;
			}
			if (INPUT_JUMP) {
				currentState = PlayerStates.JUMP;
				return;
			}
			xSpeed = gamepad_axis_value(0, gp_axislh) * moveSpeed;
			spriteDir = (INPUT_LEFT and 180);
			executeWallCollision();
			return;
		break;
		case PlayerStates.JUMP:
			if (lastState != PlayerStates.JUMP) ySpeed -= jumpPower;
			xSpeed = gamepad_axis_value(0, gp_axislh) * moveSpeed;
			spriteDir = (INPUT_LEFT and 180);
			executeWallCollision();
			return;
		break;
	}
}