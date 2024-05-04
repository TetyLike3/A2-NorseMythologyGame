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

function changeSprite(newSprite) { sprite_index = newSprite; image_index = 0; }
function changeSprite(newSprite) { sprite_index = newSprite; image_index = 0; image_speed = 1; }

function HandlePlayerState() {
	charToFace = instance_find(objCharacter,1);
	switch currentState {
		case CharacterStates.IDLE:
			if (sprite_index != sprPlayerIdle) {
				if sprite_index == sprPlayerJumpLand {
					if END_OF_SPRITE changeSprite(sprPlayerIdle);
				} else changeSprite(sprPlayerIdle);
			}
			xSpeed = 0;
			if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; return; }
			if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			if (charToFace) spriteDir = (x > charToFace.x);
		break;
		case CharacterStates.MOVE:
			if (sprite_index != sprPlayerWalk) {
				changeSprite(sprPlayerWalk);
			}
			if not (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.IDLE; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if (INPUT_JUMP and not inAir) {
				currentState = CharacterStates.JUMP;
				ySpeed += objGameManager.gameGravity;
				executeGroundCollision(); executeWallCollision();
				return;
			}
		break;
		case CharacterStates.JUMP:
			if (lastState != CharacterStates.JUMP) {
				changeSprite(sprPlayerJump); audio_play_sound(sndJump,100,false,0.4);
				ySpeed -= jumpPower;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				return;
			}
			if ((sprite_index == sprPlayerJump) and END_OF_SPRITE) changeSprite(sprPlayerAirIdle);
			
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if getGroundCollision() {
				changeSprite(sprPlayerJumpLand); audio_play_sound(sndJumpLand,100,false,4);
				if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; } else { currentState = CharacterStates.IDLE; }
				executeGroundCollision(); executeWallCollision();
				return;
			}
		break;
		case CharacterStates.LATTACK:
			if (lastState != CharacterStates.LATTACK) {
				changeSprite(sprPlayerLightSide);
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
			if END_OF_SPRITE { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				changeSprite(sprPlayerIdle);
				return;
			}
		break;
		case CharacterStates.HATTACK:
			if (lastState != CharacterStates.HATTACK) {
				changeSprite(sprPlayerLightSide);
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
			if END_OF_SPRITE { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				changeSprite(sprPlayerIdle);
				return;
			}
		break;
	}
	
	// Physics code
	if currentState == CharacterStates.MOVE {  if sign(spriteDir) != sign(xSpeed) { image_speed = -1; } else image_speed = 1; }
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
			
			if (distance_to_object(objPlayer) < 128) {
				if (irandom(100) < (aiAgressiveness/4)) { currentState = CharacterStates.LATTACK; return; }
			}
			if (irandom(100) < aiAgressiveness) { currentState = CharacterStates.MOVE; return; }
		break;
		case CharacterStates.MOVE:
			if (irandom(100) > aiAgressiveness) { currentState = CharacterStates.IDLE; return; }
			if (distance_to_object(objPlayer) < 128) { currentState = CharacterStates.IDLE; return; }
			//if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			//if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			//if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			
			if (charToFace) spriteDir = (x > charToFace.x);
			xSpeed = moveSpeed * image_xscale;
		break;
		case CharacterStates.JUMP:
			if (lastState != CharacterStates.JUMP) ySpeed -= jumpPower;
			xSpeed = getHorizontalInput() * moveSpeed;
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if getGroundCollision() { currentState = CharacterStates.IDLE; return; }
		break;
		case CharacterStates.LATTACK:
			if (lastState != CharacterStates.LATTACK) {
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
			if (END_OF_SPRITE) { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				changeSprite(sprEnemy);
				return;
			}
		break;
		case CharacterStates.HATTACK:
			if (lastState != CharacterStates.HATTACK) {
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
			if (END_OF_SPRITE) { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				instance_destroy(attackHitbox);
				attackHitbox = -1;
				changeSprite(sprEnemy);
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