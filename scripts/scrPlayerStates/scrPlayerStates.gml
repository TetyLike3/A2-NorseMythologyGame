enum PlayerStates {
	IDLE, MOVE, JUMP, ATTACK, STUN, BLOCK
}

function getHorizontalInput() {
	var input = gamepad_axis_value(0, gp_axislh);
	if keyboard_check(ord("A")) input = -1;
	if keyboard_check(ord("D")) input = 1;
	return input;
}

function HandlePlayerState() {
	switch currentState {
		case PlayerStates.IDLE:
			xSpeed = 0;
			if (INPUT_LEFT or INPUT_RIGHT) { // Switch to Move state
				currentState = PlayerStates.MOVE;
				return;
			}
			if (INPUT_JUMP) { // Switch to Jump state
				currentState = PlayerStates.JUMP;
				return;
			}
			if (INPUT_LATTACK) { // Switch to Attack state
				currentState = PlayerStates.ATTACK;
				return;
			}
		break;
		case PlayerStates.MOVE:
			if (not (INPUT_LEFT or INPUT_RIGHT)) { // Switch to Idle state
				currentState = PlayerStates.IDLE;
				return;
			}
			if (INPUT_JUMP) { // Switch to Jump state
				currentState = PlayerStates.JUMP;
				return;
			}
			if (INPUT_LATTACK) { // Switch to Attack state
				currentState = PlayerStates.ATTACK;
				return;
			}
			xSpeed = getHorizontalInput() * moveSpeed;
			spriteDir = INPUT_LEFT;
		break;
		case PlayerStates.JUMP:
			if (lastState != PlayerStates.JUMP) ySpeed -= jumpPower;
			xSpeed = getHorizontalInput() * moveSpeed;
			spriteDir = INPUT_LEFT;
			
			if getGroundCollision() { // Switch to Idle state
				currentState = PlayerStates.IDLE;
				return;
			}
		break;
		case PlayerStates.ATTACK:
			if (lastState != PlayerStates.ATTACK) {
				sprite_index = sprPlayerPunch;
				image_index = 0;
				xSpeed = 0;
				attackHitbox = instance_create_layer( x + (sprite_width/2), y - (sprite_height/2),"Instances",objHitbox);
				attackHitbox.image_xscale = image_xscale;
			}
			if (image_index == image_number) { // Switch to Idle state
				currentState = PlayerStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				sprite_index = sprPlayerIdle;
				return;
			}
		break;
	}
	ySpeed += playerGravity;
	executeGroundCollision();
	executeWallCollision();
	lastState = currentState;
}
