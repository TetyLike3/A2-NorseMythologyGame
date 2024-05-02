function print(text) {
	show_debug_message(text);
}

enum CharacterStates {
	IDLE, MOVE, JUMP, LATTACK, HATTACK, STUN, BLOCK
}

function getPlayerHorizontalInput() {
	var input = gamepad_axis_value(0, gp_axislh);
	if keyboard_check(ord("A")) input = -1;
	if keyboard_check(ord("D")) input = 1;
	return input;
}

function HandlePlayerState() {
	charToFace = instance_find(objCharacter,1);
	switch currentState {
		case CharacterStates.IDLE:
			xSpeed = 0;
			if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; return; }
			if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			if (charToFace) spriteDir = (x > charToFace.x);
		break;
		case CharacterStates.MOVE:
			if not (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.IDLE; return; }
			if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
		break;
		case CharacterStates.JUMP:
			if (lastState != CharacterStates.JUMP) ySpeed -= jumpPower;
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if getGroundCollision() { currentState = CharacterStates.IDLE; return; }
		break;
		case CharacterStates.LATTACK:
			if (lastState != CharacterStates.LATTACK) {
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
			if (round(image_index) == image_number) { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				sprite_index = sprPlayerIdle;
				return;
			}
		break;
		case CharacterStates.HATTACK:
			if (lastState != CharacterStates.HATTACK) {
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
			if (round(image_index) == image_number) { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				sprite_index = sprPlayerIdle;
				return;
			}
		break;
	}
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	inAir = not getGroundCollision();
	lastState = currentState;
}



function ProcessAIValues() {
	aiAgressiveness = charHealth;
}

function HandleAIState() {
	charToFace = instance_find(objPlayer,0);
	ProcessAIValues();
	switch currentState {
		case CharacterStates.IDLE:
			xSpeed = 0;
			//if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			//if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			//if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if (irandom(100) < aiAgressiveness) { currentState = CharacterStates.MOVE; return; }
		break;
		case CharacterStates.MOVE:
			if (irandom(100) > aiAgressiveness) { currentState = CharacterStates.IDLE; return; }
			//if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			//if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			//if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			xSpeed = getHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
		break;
		case CharacterStates.JUMP:
			if (lastState != CharacterStates.JUMP) ySpeed -= jumpPower;
			xSpeed = getHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if getGroundCollision() { currentState = CharacterStates.IDLE; return; }
		break;
		case CharacterStates.LATTACK:
			if (lastState != CharacterStates.LATTACK) {
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
			if (round(image_index) == image_number) { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				sprite_index = sprPlayerIdle;
				return;
			}
		break;
		case CharacterStates.HATTACK:
			if (lastState != CharacterStates.HATTACK) {
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
			if (round(image_index) == image_number) { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				sprite_index = sprPlayerIdle;
				return;
			}
		break;
	}
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	inAir = not getGroundCollision();
	lastState = currentState;
}