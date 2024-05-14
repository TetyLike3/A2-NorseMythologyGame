function print(text) {
	show_debug_message(text);
}

enum CharacterStates {
	IDLE, MOVE, JUMP, LATTACK, HATTACK, STUN, BLOCK, GRABBING, GRABBED, DEAD
}

function getPlayerHorizontalInput() {
	var input = gamepad_axis_value(0, gp_axislh);
	if keyboard_check(ord("A")) input = -1;
	if keyboard_check(ord("D")) input = 1;
	if (abs(input) < INPUT_DEADZONE) return 0;
	return input;
}

function hasSpriteEventOccurred(msg, shouldDelete = true) {
	var _index = array_get_index(spriteEventLog,msg);
	if (_index >= 0) {
		//print(string_concat("found ",msg," at index ",_index));
		if (shouldDelete) array_delete(spriteEventLog,_index,1);
		return _index+1;
	} else return false;
}

function changeSprite(newSprite) { sprite_index = newSprite; image_index = 0; image_speed = 1; }

function HandlePlayerState() {
	if !instance_exists(targetChar) return;
	switch currentState {
		case CharacterStates.IDLE: {
			if (sprite_index != sprPlayerIdle) {
				switch sprite_index {
					case sprPlayerJumpLand: {
						// Wait until landed jump
						if END_OF_SPRITE {
							changeSprite(sprPlayerIdle);
							canJump = true;
						}
					} break;
					case sprPlayerFloorImpact: {
						// Play get up animation
						if END_OF_SPRITE changeSprite(sprPlayerGetUp);
						return;
					} break;
					case sprPlayerLying: {
						// Play get up animation
						changeSprite(sprPlayerGetUp);
						return;
					} break;
					case sprPlayerGetUp: {
						// Wait until finished getting up
						if END_OF_SPRITE changeSprite(sprPlayerIdle);
						canJump = true;
						return;
					} break;
					default: {
						changeSprite(sprPlayerIdle);
					} break;
				}
			}
			xSpeed = 0;
			if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; return; }
			if (INPUT_JUMP and canJump) { currentState = CharacterStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			if (INPUT_GRAB) { currentState = CharacterStates.GRABBING; return; }
			
			FACE_TARGET;
		} break;
		case CharacterStates.MOVE: {
			if (sprite_index != sprPlayerWalk) changeSprite(sprPlayerWalk);
			
			if not (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.IDLE; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			if (INPUT_GRAB) { currentState = CharacterStates.GRABBING; return; }
			
			xSpeed = getPlayerHorizontalInput() * moveSpeed;
			if (instance_exists(targetChar)) { spriteDir = (x > targetChar.x); } else { spriteDir = (xSpeed < 0); }
			
			if (INPUT_JUMP and canJump) {
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
			
			FACE_TARGET;
			canJump = false;
			
			if getGroundCollision() {
				changeSprite(sprPlayerJumpLand); audio_play_sound(sndJumpLand,100,false,4);
				if (INPUT_LEFT or INPUT_RIGHT) { currentState = CharacterStates.MOVE; } else { currentState = CharacterStates.IDLE; }
				executeGroundCollision(); executeWallCollision();
				return;
			}
		} break;
		case CharacterStates.LATTACK: {
			if (lastState != CharacterStates.LATTACK) {
				changeSprite(sprPlayerLightSide1);
				xSpeed = 0;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				
				attackHitbox = instance_create_layer(x, y, "Instances", objHitbox);
				attackHitbox.sprite_index = sprPlayerLightSide1Hitbox;
				attackHitbox.image_xscale = image_xscale;
				attackHitbox.collisionDamage = lightAttackDamage;
				attackHitbox.collidable = objEnemy;
				attackHitbox.shouldStun = false;
				
				return;
			}
			attackHitbox.image_index = image_index;
			
			if END_OF_SPRITE { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				changeSprite(sprPlayerIdle);
				return;
			}
		} break;
		case CharacterStates.HATTACK: {
			if (lastState != CharacterStates.HATTACK) {
				changeSprite(sprPlayerLightSide3);
				xSpeed = 0;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				
				attackHitbox = instance_create_layer(x, y, "Instances", objHitbox);
				attackHitbox.sprite_index = sprPlayerLightSide3Hitbox;
				attackHitbox.image_xscale = image_xscale;
				attackHitbox.collisionDamage = heavyAttackDamage;
				attackHitbox.collidable = objEnemy;
				attackHitbox.shouldStun = true;
				attackHitbox.stunDir = spriteDir;
				attackHitbox.stunHeight = 18;
			}
			attackHitbox.image_index = image_index;
			
			if END_OF_SPRITE { // Switch to Idle state
				currentState = CharacterStates.IDLE;
				changeSprite(sprPlayerIdle);
				return;
			}
		} break;
		case CharacterStates.STUN: {
			if (lastState != CharacterStates.STUN) {
				changeSprite(sprPlayerInjured);
				if (instance_exists(targetChar) and targetChar.spriteDir) { xSpeed = -9; } else xSpeed = 9;
				ySpeed = -abs(xSpeed*2);
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				stunTimer = stunTimerMax;
				
				if instance_exists(attackHitbox) instance_destroy(attackHitbox);
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
					if (charHealth <= 0) { currentState = CharacterStates.DEAD; return; }
					if ((sprite_index == sprPlayerFloorImpact) and END_OF_SPRITE) changeSprite(sprPlayerLying);
				}
				if (stunTimer < 1) {
					currentState = CharacterStates.IDLE;
				}
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
			FACE_TARGET;
		} break;
		case CharacterStates.GRABBING: {
			if (sprite_index != sprPlayerGrab) and (sprite_index != sprPlayerGrabHolding) and (sprite_index != sprPlayerForwardThrow) {
				changeSprite(sprPlayerGrab);
				xSpeed = 0;
			}
			if hasSpriteEventOccurred("GrabStart") {
				var _grabbable = place_meeting(x,y,targetChar);
				if _grabbable and (
					targetChar.currentState == CharacterStates.BLOCK
					or targetChar.currentState == CharacterStates.LATTACK
					or targetChar.currentState == CharacterStates.HATTACK
				) {
					targetChar.currentState = CharacterStates.GRABBED;
					targetChar.x = x+(128*image_xscale);
					targetChar.y = y-32;
				}
			}
			if hasSpriteEventOccurred("GrabEnd") {
				if (targetChar.currentState == CharacterStates.GRABBED) {
					if (sprite_index == sprPlayerGrab) {
						if INPUT_GRAB {
							if (targetChar.currentState == CharacterStates.GRABBED) { changeSprite(sprPlayerGrabHolding); }
						} else {
							targetChar.TakeDamage(heavyAttackDamage);
							if (spriteDir) { targetChar.GetStunned(0,18); } else { targetChar.GetStunned(1,18); }
						}
					} else if (sprite_index == sprPlayerForwardThrow) {
						targetChar.TakeDamage(heavyAttackDamage*1.1);
						if (spriteDir) { targetChar.GetStunned(0,22); } else { targetChar.GetStunned(1,22); }
					}
				}
			}
			if END_OF_SPRITE {
				if (sprite_index == sprPlayerGrabHolding) {
					changeSprite(sprPlayerForwardThrow);
				} else if (sprite_index == sprPlayerForwardThrow) or (sprite_index == sprPlayerGrab) {
					currentState = CharacterStates.IDLE;
				}
			}
		} break;
		case CharacterStates.GRABBED: {
			if (sprite_index != sprPlayerInjured) {
				changeSprite(sprPlayerInjured);
				xSpeed = 0; ySpeed = 0;
			}
		} break;
		case CharacterStates.DEAD: {
			if (sprite_index != sprPlayerLying) {
				changeSprite(sprPlayerLying);
				xSpeed = 0; ySpeed = 0;
				charHealth = 0;
			}
		}
	}
	
	if instance_exists(attackHitbox) {
		if (currentState != CharacterStates.LATTACK) and (currentState != CharacterStates.HATTACK) {
			print("destroyed hitbox");
			instance_destroy(attackHitbox);
			attackHitbox = undefined;
		}
	}
	
	// Physics code
	if currentState == CharacterStates.MOVE {  if (sign(spriteDir) != sign(xSpeed)) { image_speed = 1; } else image_speed = -1; }
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	canJump = getGroundCollision();
	lastState = currentState;
}

function HandleDummyState() {
	switch currentState {
		case CharacterStates.IDLE: {
			if (sprite_index != sprPlayerIdle) {
				if sprite_index == sprPlayerJumpLand {
					if END_OF_SPRITE {
						changeSprite(sprPlayerIdle);
					}
				} else changeSprite(sprPlayerIdle);
			}
			xSpeed = 0;
			
			FACE_TARGET;
		} break;
		case CharacterStates.STUN: {
			if (lastState != CharacterStates.STUN) {
				changeSprite(sprPlayerInjured);
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
					if (charHealth <= 0) { currentState = CharacterStates.DEAD; return; }
					if ((sprite_index == sprPlayerFloorImpact) and END_OF_SPRITE) changeSprite(sprPlayerLying);
				}
				if (stunTimer < 1) {
					currentState = CharacterStates.IDLE;
				}
			}
		} break;
		case CharacterStates.DEAD: {
			if (sprite_index != sprPlayerLying) {
				changeSprite(sprPlayerLying);
				xSpeed = 0; ySpeed = 0;
				charHealth = 0;
			}
		}
	}
	
	// Physics code
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	lastState = currentState;
}

function HandleAIState() {
	if (currentState != lastState) stateChangeCD = stateChangeCDMax;
	StepNeuralNetwork();
	
	switch currentState {
		case CharacterStates.IDLE: {
			if (sprite_index != sprPlayerIdle) {
				switch sprite_index {
					case sprPlayerJumpLand: {
						// If current sprite is sprPlayerJumpLand then wait until it's done before changing
						if END_OF_SPRITE {
							changeSprite(sprPlayerIdle);
							canJump = true;
						}
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
						canJump = true;
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
			
			if (aiXInput != 0) and !stateChangeCD { currentState = CharacterStates.MOVE; return; }
			if (aiJumpInput and canJump) and !stateChangeCD { currentState = CharacterStates.JUMP; return; }
			if (aiLightAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.LATTACK; return; }
			if (aiHeavyAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.HATTACK; return; }
			if (aiBlockInput) and !stateChangeCD { currentState = CharacterStates.BLOCK; return; }
			if (aiGrabInput) and !stateChangeCD { currentState = CharacterStates.GRABBING; return; }
		} break;
		case CharacterStates.MOVE: {
			// Change sprite
			if (sprite_index != sprPlayerWalk) changeSprite(sprPlayerWalk);
			
			FACE_TARGET;
			// Update speed
			xSpeed = aiXInput * moveSpeed;
			
			if (xSpeed != 0) aiTimeSinceMove = 0;
			
			/*
			if (aiShouldJump and not canJump) {
				currentState = CharacterStates.JUMP;
				ySpeed += objGameManager.gameGravity;
				executeGroundCollision(); executeWallCollision();
				return;
			}
			*/
			if (aiXInput == 0) and !stateChangeCD { currentState = CharacterStates.IDLE; return; }
			if (aiJumpInput and canJump) and !stateChangeCD { currentState = CharacterStates.JUMP; return; }
			if (aiLightAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.LATTACK; return; }
			if (aiHeavyAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.HATTACK; return; }
			if (aiBlockInput) and !stateChangeCD { currentState = CharacterStates.BLOCK; return; }
			if (aiGrabInput) and !stateChangeCD { currentState = CharacterStates.GRABBING; return; }
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
			
			xSpeed = aiXInput * moveSpeed;
			FACE_TARGET;
			canJump = false;
			
			// If landed, switch to idle state
			if getGroundCollision() {
				changeSprite(sprPlayerJumpLand); audio_play_sound(sndJumpLand,100,false,4);
				if (aiXInput) { currentState = CharacterStates.MOVE; } else { currentState = CharacterStates.IDLE; }
				executeGroundCollision(); executeWallCollision();
				return;
			}
		} break;
		case CharacterStates.LATTACK: {
			if (lastState != CharacterStates.LATTACK) {
				changeSprite(sprPlayerLightSide1);
				xSpeed = 0;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				
				attackHitbox = instance_create_layer(x, y, "Instances", objHitbox);
				attackHitbox.sprite_index = sprPlayerLightSide1Hitbox;
				attackHitbox.image_xscale = image_xscale;
				attackHitbox.collisionDamage = lightAttackDamage;
				attackHitbox.collidable = targetChar;
				attackHitbox.shouldStun = false;
				return;
			}
			attackHitbox.image_index = image_index;
			
			if (END_OF_SPRITE) { // Switch to Idle state
				currentState = CharacterStates.IDLE; lastState = currentState;
				changeSprite(sprPlayerIdle);
				
				aiTimeSinceAttack = 0;
				aiAttackCD = (aiAttackCDMax) * max(4-(aiTimeSinceAttack/10),0);
				return;
			}
		} break;
		case CharacterStates.HATTACK: {
			if (lastState != CharacterStates.HATTACK) {
				changeSprite(sprPlayerLightSide3);
				xSpeed = 0;
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				
				attackHitbox = instance_create_layer(x, y, "Instances", objHitbox);
				attackHitbox.sprite_index = sprPlayerLightSide3Hitbox;
				attackHitbox.image_xscale = image_xscale;
				attackHitbox.collisionDamage = heavyAttackDamage;
				attackHitbox.collidable = targetChar;
				attackHitbox.shouldStun = true;
				attackHitbox.stunDir = spriteDir;
				attackHitbox.stunHeight = 18;
				return;
			}
			attackHitbox.image_index = image_index;
			
			if (END_OF_SPRITE) { // Switch to Idle state
				currentState = CharacterStates.IDLE; lastState = currentState;
				changeSprite(sprPlayerIdle);
				
				aiTimeSinceAttack = 0;
				aiAttackCD = (aiAttackCDMax) * max(4-(aiTimeSinceAttack/10),0);
				return;
			}
		} break;
		case CharacterStates.STUN: {
			if (lastState != CharacterStates.STUN) {
				changeSprite(sprPlayerInjured);
				stunBounce = stunBounceMax;
				if (instance_exists(targetChar) and targetChar.spriteDir) { xSpeed = -stunBounce*3; } else xSpeed = stunBounce*3;
				ySpeed = -abs(stunBounce*6);
				executeGroundCollision(); executeWallCollision();
				lastState = currentState;
				stunTimer = stunTimerMax;
				
				if instance_exists(attackHitbox) instance_destroy(attackHitbox);
				return;
			}
			
			// Every bounce, reduce speed until below 2, then freeze
			if getGroundCollision() {
				stunBounce--;
				if (stunBounce > 0) {
					changeSprite(sprPlayerFloorImpact);
					xSpeed/=3; ySpeed = -abs(stunBounce*6);
					executeGroundCollision(); executeWallCollision();
					return;
				} else {
					xSpeed = 0; ySpeed = 0;
					if (charHealth <= 0) { currentState = CharacterStates.DEAD; return; }
					if ((sprite_index == sprPlayerFloorImpact) and END_OF_SPRITE) changeSprite(sprPlayerLying);
				}
				if (stunTimer < 1) {
					currentState = CharacterStates.IDLE;
				}
			}
		} break;
		case CharacterStates.BLOCK: {
			if (sprite_index != sprPlayerBlock) {
				changeSprite(sprPlayerBlock);
				xSpeed = 0;
			}
			if (not aiBlockInput) {
				currentState = CharacterStates.IDLE;
			}
			if END_OF_SPRITE image_index = 3;
			FACE_TARGET;
		} break;
		case CharacterStates.GRABBING: {
			if (sprite_index != sprPlayerGrab) and (sprite_index != sprPlayerGrabHolding) and (sprite_index != sprPlayerForwardThrow) {
				changeSprite(sprPlayerGrab);
				xSpeed = 0;
			}
			if hasSpriteEventOccurred("GrabStart") {
				var _grabbable = place_meeting(x,y,targetChar);
				if _grabbable and (
					targetChar.currentState == CharacterStates.BLOCK
					or targetChar.currentState == CharacterStates.LATTACK
					or targetChar.currentState == CharacterStates.HATTACK
				) {
					targetChar.currentState = CharacterStates.GRABBED;
					targetChar.x = x+(128*image_xscale);
					targetChar.y = y-32;
				}
			}
			if hasSpriteEventOccurred("GrabEnd") {
				if (targetChar.currentState == CharacterStates.GRABBED) {
					if (sprite_index == sprPlayerGrab) {
						if aiGrabInput {
							if (targetChar.currentState == CharacterStates.GRABBED) {
								changeSprite(sprPlayerGrabHolding);
							}
						} else {
							targetChar.TakeDamage(10);
							if (spriteDir) { targetChar.GetStunned(0,18); } else { targetChar.GetStunned(1,18); }
						}
					} else if (sprite_index == sprPlayerForwardThrow) {
						targetChar.TakeDamage(15);
						if (spriteDir) { targetChar.GetStunned(0,22); } else { targetChar.GetStunned(1,22); }
					}
				}
			}
			if END_OF_SPRITE {
				if (sprite_index == sprPlayerGrabHolding) {
					changeSprite(sprPlayerForwardThrow);
				} else if (sprite_index == sprPlayerForwardThrow) or (sprite_index == sprPlayerGrab) {
					currentState = CharacterStates.IDLE;
				}
			}
		} break;
		case CharacterStates.GRABBED: {
			if (sprite_index != sprPlayerInjured) {
				changeSprite(sprPlayerInjured);
				xSpeed = 0; ySpeed = 0;
			}
		} break;
		case CharacterStates.DEAD: {
			if (sprite_index != sprPlayerLying) {
				changeSprite(sprPlayerLying);
				xSpeed = 0; ySpeed = 0;
				charHealth = 0;
			}
		}
	}
	
	if instance_exists(attackHitbox) {
		if (currentState != CharacterStates.LATTACK) and (currentState != CharacterStates.HATTACK) {
			if (array_length(attackHitbox.collidedWith) < 1) aiMissCount++;
			instance_destroy(attackHitbox);
			attackHitbox = undefined;
		}
	}
	
	// Physics code
	if currentState == CharacterStates.MOVE { 
		if sign(spriteDir) != sign(xSpeed) { image_speed = -1; } else image_speed = 1; 
	} else image_speed = 1;
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	canJump = getGroundCollision();
	lastState = currentState;
}