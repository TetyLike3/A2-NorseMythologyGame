enum PlayerStates {
	IDLE, MOVE, ATTACK, STUN, BLOCK
}

function HandlePlayerState() {
	switch currentState {
		case PlayerStates.IDLE:
			if (INPUT_LEFT or INPUT_RIGHT) {
				currentState = PlayerStates.MOVE;
			}
		break;
		case PlayerStates.MOVE:
			xSpeed = gamepad_axis_value(0, gp_axislh) * moveSpeed;
			if (not (INPUT_LEFT or INPUT_RIGHT)) currentState = PlayerStates.IDLE;
			spriteDir = (INPUT_LEFT and 180);
			x += xSpeed;
		break;
	}
}