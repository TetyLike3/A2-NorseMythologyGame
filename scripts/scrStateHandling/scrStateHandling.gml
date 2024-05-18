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
function getPlayerVerticalInput() {
	var input = gamepad_axis_value(0, gp_axislv);
	if keyboard_check(ord("S")) input = -1;
	if keyboard_check(ord("W")) input = 1;
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


function baseIdleState() {
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
		
	FACE_TARGET;
	
	if abs(inputVector[0]) { currentState = CharacterStates.MOVE; return; }
}
function baseMoveState() {
	if (sprite_index != sprPlayerWalk) changeSprite(sprPlayerWalk);
	
	if (instance_exists(targetChar)) { spriteDir = (x < targetChar.x); } else { spriteDir = (xSpeed > 0); }
	
	xSpeed = inputVector[0] * moveSpeed;
	
	if !abs(inputVector[0]) { currentState = CharacterStates.IDLE; return; }
}
function baseJumpState() {
	if (lastState != CharacterStates.JUMP) {
		if (staminaLevel < staminaJumpCost) { currentState = lastState; return; }
		staminaLevel -= staminaJumpCost; staminaRegenTimer = staminaRegenTimerMax;
				
		changeSprite(sprPlayerJump); audio_play_sound(sndJump,100,false,0.4);
		ySpeed -= jumpPower;
		executeGroundCollision(); executeWallCollision();
		lastState = currentState;
		return;
	}
	if ((sprite_index == sprPlayerJump) and END_OF_SPRITE) changeSprite(sprPlayerAirIdle);
	
	xSpeed = inputVector[0] * moveSpeed;
			
	FACE_TARGET;
	canJump = false;
	
	if getGroundCollision() {
		changeSprite(sprPlayerJumpLand); audio_play_sound(sndJumpLand,100,false,4);
		if (inputVector[0]) { currentState = CharacterStates.MOVE; } else { currentState = CharacterStates.IDLE; }
		executeGroundCollision(); executeWallCollision();
		return;
	}
}
function baseLAttackState() {
	if (lastState != CharacterStates.LATTACK) {
		if (staminaLevel < staminaLAttackCost) { currentState = lastState; return; }
		staminaLevel -= staminaLAttackCost; staminaRegenTimer = staminaRegenTimerMax;
		
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
	
	if END_OF_SPRITE { // Switch to Idle state
		currentState = CharacterStates.IDLE;
		changeSprite(sprPlayerIdle);
		return;
	}
}
function baseHAttackState() {
	if (lastState != CharacterStates.HATTACK) {
		if (staminaLevel < staminaHAttackCost) { currentState = lastState; return; }
		staminaLevel -= staminaHAttackCost; staminaRegenTimer = staminaRegenTimerMax;
		
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
	}
	attackHitbox.image_index = image_index;
	
	if END_OF_SPRITE { // Switch to Idle state
		currentState = CharacterStates.IDLE;
		changeSprite(sprPlayerIdle);
		return;
	}
}
function baseStunnedState() {
	if (lastState != CharacterStates.STUN) {
		changeSprite(sprPlayerInjured);
		stunBounce = stunBounceMax;
		//if (instance_exists(targetChar) and targetChar.spriteDir) { xSpeed = stunBounce*3; } else xSpeed = -stunBounce*3;
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
}
function baseBlockState(_blockInput) {
	if (sprite_index != sprPlayerBlock) {
		changeSprite(sprPlayerBlock);
		xSpeed = 0;
	}
	if (not _blockInput) { currentState = CharacterStates.IDLE; }
	if END_OF_SPRITE image_index = 3;
	FACE_TARGET;
}
function baseGrabbingState(_grabInput) {
	if (lastState != CharacterStates.GRABBING) {
		if (staminaLevel < staminaGrabCost) { currentState = lastState; return; }
		staminaLevel -= staminaGrabCost; staminaRegenTimer = staminaRegenTimerMax;
		
		lastState = currentState;
		return;
	}
	
	if (sprite_index != sprPlayerGrab) and (sprite_index != sprPlayerGrabHolding) and (sprite_index != sprPlayerForwardThrow) {
		changeSprite(sprPlayerGrab);
		xSpeed = 0;
	}
	if hasSpriteEventOccurred("GrabStart") {
		var _grabbable = place_meeting(x,y,targetChar);
		if _grabbable /*and (
			targetChar.currentState == CharacterStates.BLOCK
			or targetChar.currentState == CharacterStates.LATTACK
			or targetChar.currentState == CharacterStates.HATTACK
		)*/ {
			targetChar.currentState = CharacterStates.GRABBED;
			targetChar.x = x+(128*image_xscale);
			targetChar.y = y-32;
		}
	}
	if hasSpriteEventOccurred("GrabEnd") {
		if (targetChar.currentState == CharacterStates.GRABBED) {
			if (sprite_index == sprPlayerGrab) {
				if _grabInput {
					if (targetChar.currentState == CharacterStates.GRABBED) { changeSprite(sprPlayerGrabHolding); }
				} else {
					targetChar.TakeDamage(heavyAttackDamage);
					if (spriteDir) { targetChar.GetStunned(0,18); } else { targetChar.GetStunned(1,18); }
				}
			} else if (sprite_index == sprPlayerForwardThrow) {
				targetChar.TakeDamage(heavyAttackDamage*1.1);
				if (spriteDir) { targetChar.GetStunned(1,22); } else { targetChar.GetStunned(0,22); }
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
}
function baseGrabbedState() {
	if (sprite_index != sprPlayerInjured) {
		changeSprite(sprPlayerInjured);
		xSpeed = 0; ySpeed = 0;
	}
}
function baseDeadState() {
	if (sprite_index != sprPlayerLying) {
		changeSprite(sprPlayerLying);
		xSpeed = 0; ySpeed = 0;
		charHealth = 0;
	}
}
function basePhysics() {
	if currentState == CharacterStates.MOVE {  if (sign(spriteDir) != sign(xSpeed)) { image_speed = -1; } else image_speed = 1; }
	ySpeed += objGameManager.gameGravity;
	executeGroundCollision();
	executeWallCollision();
	canJump = getGroundCollision();
	lastState = currentState;
}


function HandlePlayerState() {
	if !instance_exists(targetChar) return;
	switch currentState {
		case CharacterStates.IDLE: {
			baseIdleState();
			
			if (INPUT_JUMP and canJump) { currentState = CharacterStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			if (INPUT_GRAB) { currentState = CharacterStates.GRABBING; return; }
		} break;
		case CharacterStates.MOVE: {
			baseMoveState();

			if (INPUT_JUMP and canJump) { currentState = CharacterStates.JUMP; return; }
			if (INPUT_LATTACK) { currentState = CharacterStates.LATTACK; return; }
			if (INPUT_HATTACK) { currentState = CharacterStates.HATTACK; return; }
			if (INPUT_BLOCK) { currentState = CharacterStates.BLOCK; return; }
			if (INPUT_GRAB) { currentState = CharacterStates.GRABBING; return; }
		} break;
		case CharacterStates.JUMP: {
			baseJumpState();
		} break;
		case CharacterStates.LATTACK: {
			baseLAttackState();
		} break;
		case CharacterStates.HATTACK: {
			baseHAttackState();
		} break;
		case CharacterStates.STUN: {
			baseStunnedState();
		} break;
		case CharacterStates.BLOCK: {
			baseBlockState(INPUT_BLOCK);
		} break;
		case CharacterStates.GRABBING: {
			baseGrabbingState(INPUT_GRAB);
		} break;
		case CharacterStates.GRABBED: {
			baseGrabbedState();
		} break;
		case CharacterStates.DEAD: {
			baseDeadState();
		}
	}
	
	if instance_exists(attackHitbox) {
		if (currentState != CharacterStates.LATTACK) and (currentState != CharacterStates.HATTACK) {
			instance_destroy(attackHitbox);
			attackHitbox = undefined;
		}
	}
	
	if (INPUT_RIGHT) attackDir = 0;
	if (INPUT_DOWN) attackDir = 1;
	if (INPUT_LEFT) attackDir = 2;
	if (INPUT_UP) attackDir = 3;
	
	// Physics code
	basePhysics();
}

function HandleDummyState() {
	switch currentState {
		case CharacterStates.IDLE: {
			baseIdleState();
		} break;
		case CharacterStates.STUN: {
			baseStunnedState();
		} break;
		case CharacterStates.DEAD: {
			baseDeadState();
		}
	}
	basePhysics();
}

function HandleAIState() {
	if (currentState != lastState) stateChangeCD = stateChangeCDMax;
	StepNeuralNetwork();
	
	switch currentState {
		case CharacterStates.IDLE: {
			baseIdleState();
			
			if (aiJumpInput and canJump) { currentState = CharacterStates.JUMP; return; }
			if (aiLightAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.LATTACK; return; }
			if (aiHeavyAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.HATTACK; return; }
			if (aiBlockInput) and !stateChangeCD { currentState = CharacterStates.BLOCK; return; }
			if (aiGrabInput) and !stateChangeCD { currentState = CharacterStates.GRABBING; return; }
		} break;
		case CharacterStates.MOVE: {
			baseMoveState();
			
			if (xSpeed != 0) aiTimeSinceMove = 0;
			
			if (aiJumpInput and canJump) { currentState = CharacterStates.JUMP; return; }
			if (aiLightAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.LATTACK; return; }
			if (aiHeavyAttackInput) and !stateChangeCD and !aiAttackCD { currentState = CharacterStates.HATTACK; return; }
			if (aiBlockInput) and !stateChangeCD { currentState = CharacterStates.BLOCK; return; }
			if (aiGrabInput) and !stateChangeCD { currentState = CharacterStates.GRABBING; return; }
		} break;
		case CharacterStates.JUMP: {
			baseJumpState();
		} break;
		case CharacterStates.LATTACK: {
			if (END_OF_SPRITE) {
				aiTimeSinceAttack = 0;
				aiAttackCD = (aiAttackCDMax) * max(4-(aiTimeSinceAttack/10),0);
			}
			baseLAttackState();
		} break;
		case CharacterStates.HATTACK: {
			if (END_OF_SPRITE) {
				aiTimeSinceAttack = 0;
				aiAttackCD = (aiAttackCDMax) * max(4-(aiTimeSinceAttack/10),0);
			}
			baseHAttackState();
		} break;
		case CharacterStates.STUN: {
			baseStunnedState();
		} break;
		case CharacterStates.BLOCK: {
			baseBlockState(aiBlockInput);
		} break;
		case CharacterStates.GRABBING: {
			baseGrabbingState(aiGrabInput);
		} break;
		case CharacterStates.GRABBED: {
			baseGrabbedState();
		} break;
		case CharacterStates.DEAD: {
			baseDeadState();
		}
	}
	
	if instance_exists(attackHitbox) {
		if (currentState != CharacterStates.LATTACK) and (currentState != CharacterStates.HATTACK) {
			if (array_length(attackHitbox.collidedWith) < 1) aiMissCount++;
			instance_destroy(attackHitbox);
			attackHitbox = undefined;
		}
	}
	
	if (aiInputRight) attackDir = 0;
	if (aiInputDown) attackDir = 1;
	if (aiInputLeft) attackDir = 2;
	if (aiInputUp) attackDir = 3;
	
	// Physics code
	basePhysics();
}