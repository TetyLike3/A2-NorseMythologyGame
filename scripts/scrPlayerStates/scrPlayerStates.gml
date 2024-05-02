enum PlayerStates {
	IDLE, MOVE, JUMP, LATTACK, HATTACK, STUN, BLOCK
}

function getHorizontalInput() {
	var input = gamepad_axis_value(0, gp_axislh);
	if keyboard_check(ord("A")) input = -1;
	if keyboard_check(ord("D")) input = 1;
	return input;
}

function HandlePlayerState() {
	charToFace = instance_find(objCharacter,1);
	switch currentState {
		case PlayerStates.IDLE:
			xSpeed = 0;
			if (INPUT_LEFT or INPUT_RIGHT) { currentState = PlayerStates.MOVE; return; }
			if (INPUT_JUMP) { currentState = PlayerStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = PlayerStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = PlayerStates.HATTACK; return; }
			
			if (charToFace) spriteDir = (x > charToFace.x);
		break;
		case PlayerStates.MOVE:
			if not (INPUT_LEFT or INPUT_RIGHT) { currentState = PlayerStates.IDLE; return; }
			if (INPUT_JUMP) { currentState = PlayerStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = PlayerStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = PlayerStates.HATTACK; return; }
			
			xSpeed = getHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
		break;
		case PlayerStates.JUMP:
			if (lastState != PlayerStates.JUMP) ySpeed -= jumpPower;
			xSpeed = getHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if getGroundCollision() { currentState = PlayerStates.IDLE; return; }
		break;
		case PlayerStates.LATTACK:
			if (lastState != PlayerStates.LATTACK) {
				sprite_index = sprPlayerPunch;
				image_index = 0;
				xSpeed = 0;
				attackHitbox = instance_create_layer(
					x + (sprite_width/2),
					y - (sprite_height/2),
					"Instances",
					objHitbox
				);
				attackHitbox.image_xscale = image_xscale;
				attackHitbox.collisionDamage = lightAttackDamage;
			}
			if (image_index == image_number) { // Switch to Idle state
				currentState = PlayerStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				sprite_index = sprPlayerIdle;
				return;
			}
		break;
		case PlayerStates.HATTACK:
			if (lastState != PlayerStates.HATTACK) {
				sprite_index = sprPlayerPunch;
				image_index = 0;
				xSpeed = 0;
				attackHitbox = instance_create_layer(
					x + (sprite_width/2),
					y - (sprite_height/2),
					"Instances",
					objHitbox
				);
				attackHitbox.image_xscale = image_xscale;
				attackHitbox.collisionDamage = heavyAttackDamage;
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