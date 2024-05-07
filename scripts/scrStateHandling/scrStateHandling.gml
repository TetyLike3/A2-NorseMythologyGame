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

function changeSprite(newSprite) { sprite_index = newSprite; image_index = 0; image_speed = 1; }

function HandlePlayerState() {
	charToFace = instance_find(objCharacter,1);
	switch currentState {
		case CharacterStates.IDLE: {
			if (sprite_index != sprPlayerIdle) {
				if sprite_index == sprPlayerJumpLand {
					if END_OF_SPRITE changeSprite(sprPlayerIdle);
				} else changeSprite(sprPlayerIdle);
			}
			xSpeed = 0;
			//if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; return; }
			//if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			//if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			//if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			//if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			
			FACE_TARGET;
		} break;
		case CharacterStates.MOVE: {
			if (sprite_index != sprPlayerWalk) changeSprite(sprPlayerWalk);
			
			if not (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.IDLE; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			if (charToFace) { spriteDir = (x > charToFace.x); } else { spriteDir = (xSpeed < 0); }
			
			if (INPUT_JUMP and not inAir) {
				currentState = CharacterStates.JUMP;
				ySpeed += objGameManager.gameGravity;
				executeGroundCollision(); executeWallCollision();
				return;
			}
		} break;
		case CharacterStates.JUMP: {
			if (lastState != CharacterStates.JUMP) {
				changeSprite(sprPlayerJump); audio_play_sound(sndJump,100,false,0.4);
				ySpeed -= jumpPower;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				return;
			}
			if ((sprite_index == sprPlayerJump) and END_OF_SPRITE) changeSprite(sprPlayerAirIdle);
			if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			
			if (charToFace) spriteDir = (x > charToFace.x);
			
			if getGroundCollision() {
				changeSprite(sprPlayerJumpLand); audio_play_sound(sndJumpLand,100,false,4);
				if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; } else { currentState = CharacterStates.IDLE; }
				executeGroundCollision(); executeWallCollision();
				return;
			}
		} break;
		case CharacterStates.LATTACK: {
			if (lastState != CharacterStates.LATTACK) {
				changeSprite(sprPlayerHeavySide);
				xSpeed = 0;
			}
			if (image_index >= 8) and (not attackHitbox) {
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
		} break;
		case CharacterStates.HATTACK: {
			if (lastState != CharacterStates.HATTACK) {
				changeSprite(sprPlayerHeavySide);
				xSpeed = 0;
			}
			if (image_index >= 8) and (not attackHitbox) {
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
		} break;
		case CharacterStates.BLOCK: {
			if (sprite_index != sprPlayerBlock) {
				changeSprite(sprPlayerBlock);
				xSpeed = 0;
			}
			if (not INPUT_BLOCK) {
				currentState = CharacterStates.IDLE;
			}
			if END_OF_SPRITE image_index = 3;
		} break;
	}
	
	// Physics code
	if currentState == CharacterStates.MOVE {  if (sign(spriteDir) != sign(xSpeed)) { image_speed = 1; } else image_speed = -1; }
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	inAir = not getGroundCollision();
	lastState = currentState;
}

function HandleAIState() {
	//charToFace = instance_find(objPlayer,0);
	StepNeuralNetwork();
	switch currentState {
		case CharacterStates.IDLE: {
			if (sprite_index != sprPlayerIdle) {
				switch sprite_index {
					case sprPlayerJumpLand: {
						// If current sprite is sprPlayerJumpLand then wait until it's done before changing
						if END_OF_SPRITE changeSprite(sprPlayerIdle);
					} break;
					case sprPlayerFloorImpact: {
						if END_OF_SPRITE changeSprite(sprPlayerGetUp);
						return;
					} break;
					case sprPlayerLying: {
						changeSprite(sprPlayerGetUp);
						return;
					} break;
					case sprPlayerGetUp: {
						if END_OF_SPRITE changeSprite(sprPlayerIdle);
						return;
					} break;
					default: {
						changeSprite(sprPlayerIdle);
					} break;
				}
			}
			// Reset speed
			xSpeed = 0;
			
			FACE_TARGET;
			
			if (aiXInput != 0) { currentState = CharacterStates.MOVE; return; }
			//if (INPUT_JUMP and not inAir) { currentState = CharacterStates.JUMP; return; }
			//if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			//if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			//if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
		} break;
		case CharacterStates.MOVE: {
			// Change sprite
			if (sprite_index != sprPlayerWalk) changeSprite(sprPlayerWalk);
			
			FACE_TARGET;
			// Update speed
			xSpeed = aiXInput * moveSpeed;
			
			/*
			if (aiShouldJump and not inAir) {
				currentState = CharacterStates.JUMP;
				ySpeed += objGameManager.gameGravity;
				executeGroundCollision(); executeWallCollision();
				return;
			}
			*/
		} break;
		case CharacterStates.JUMP: {
			// If just started jumping, change sprite, play sound, and end early
			if (lastState != CharacterStates.JUMP) {
				changeSprite(sprPlayerJump); audio_play_sound(sndJump,100,false,0.4);
				ySpeed -= jumpPower;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				return;
			}
			// Switch to sprAirIdle if sprPlayerJump anim ended
			if ((sprite_index == sprPlayerJump) and END_OF_SPRITE) changeSprite(sprPlayerAirIdle);
			
			xSpeed = getHorizontalInput() * moveSpeed;
			FACE_TARGET;
			
			// If landed, switch to idle state
			if getGroundCollision() {
				changeSprite(sprPlayerJumpLand); audio_play_sound(sndJumpLand,100,false,4);
				if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; } else { currentState = CharacterStates.IDLE; }
				executeGroundCollision(); executeWallCollision();
				return;
			}
		} break;
		case CharacterStates.LATTACK: {
			if (lastState != CharacterStates.LATTACK) {
				changeSprite(sprPlayerHeavySide);
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
				changeSprite(sprPlayerIdle);
				return;
			}
		} break;
		case CharacterStates.HATTACK: {
			if (lastState != CharacterStates.LATTACK) {
				changeSprite(sprPlayerHeavySide);
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
				changeSprite(sprPlayerIdle);
				return;
			}
		} break;
		case CharacterStates.STUN: {
			if (lastState != CharacterStates.STUN) {
				changeSprite(sprPlayerInjured);
				if charToFace.spriteDir { xSpeed = -9; } else xSpeed = 9;
				ySpeed = -abs(xSpeed*2);
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				stunTimer = stunTimerMax;
				return;
			}
			
			// Every bounce, reduce speed until below 2, then freeze
			if getGroundCollision() {
				if (abs(xSpeed) > 2) {
					changeSprite(sprPlayerFloorImpact);
					xSpeed/=3; ySpeed = -abs(xSpeed*3);
					executeGroundCollision(); executeWallCollision();
					return;
				} else {
					xSpeed = 0; ySpeed = 0;
					if ((sprite_index == sprPlayerFloorImpact) and END_OF_SPRITE) changeSprite(sprPlayerLying);
				}
				if (stunTimer < 1) {
					currentState = CharacterStates.IDLE;
					print(sprite_index);
				}
			}
		} break;
		case CharacterStates.BLOCK: {
			if (sprite_index != sprPlayerBlock) {
				changeSprite(sprPlayerBlock);
				xSpeed = 0;
			}
			/*
			if (not INPUT_BLOCK) {
				currentState = CharacterStates.IDLE;
			}
			*/
			if END_OF_SPRITE image_index = 3;
		} break;
	}
	
	// Physics code
	if currentState == CharacterStates.MOVE { 
		if sign(spriteDir) != sign(xSpeed) { image_speed = -1; } else image_speed = 1; 
	} else image_speed = 1;
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	inAir = not getGroundCollision();
	lastState = currentState;
}