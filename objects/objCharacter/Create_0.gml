targetChar = undefined;

// Health
charHealth = charHealthMax;
damageTimer = 0;
damageTimerMax = 180;
damageFlashInterval = 15;
uTint = shader_get_uniform(sdrTint,"u_TintColour");

// Stamina
staminaLevel = 100;
staminaRegenTimerMax = 180;
staminaRegenTimer = staminaRegenTimerMax;
staminaRegenRate = 0.8;

staminaJumpCost = 0;
staminaLAttackCost = 2;
staminaHAttackCost = 8;
staminaBlockCost = 20;
staminaGrabCost = 28;

// Physics
moveSpeed = 12;
jumpPower = 18;

inputVector = [0,0];
canJump = false;
currentState = CharacterStates.IDLE;
lastState = currentState;
stateChangeCDMax = 5;
stateChangeCD = 0;

xSpeed = 0;
ySpeed = 0;
canCollideX = true;
canCollideY = true;

stunBounceMax = 3;
stunBounce = 0;

// Visual
spriteDir = 1; // 0: Left, 1: Right

spriteIndices = {
	Idle : sprPlayerIdle,
	Walk : sprPlayerWalk,
	Dash : sprPlayerDash,
	AirIdle : sprPlayerAirIdle,
	Jump : sprPlayerJump,
	JumpLand : sprPlayerJumpLand,
	
	Block : sprPlayerBlock,
	Grab : sprPlayerGrab,
	GrabHolding : sprPlayerGrabHolding,
	Throwing : {
		Up : sprPlayerUpThrow,
		Down : sprPlayerDownThrow,
		Side : sprPlayerForwardThrow,
	},
	InjuryLight : sprPlayerInjuredLight,
	InjuryHeavy : sprPlayerInjuredHeavy,
	FloorImpact : sprPlayerFloorImpact,
	Lying : sprPlayerLying,
	GetUp : sprPlayerGetUp,
	
	AttacksLight : {
		Ground : {
			Up : [sprPlayerLightUp, sprPlayerLightUpHitbox],
			Down : [sprPlayerLightDown, sprPlayerLightDownHitbox],
			Side : [sprPlayerLightSide,sprPlayerLightSideHitbox],
		},
		Air : {
			Up : [sprPlayerLightAirUp, sprPlayerLightAirUpHitbox],
			Down : [sprPlayerLightAirDown, sprPlayerLightAirDownHitbox],
			Side : [sprPlayerLightAirSide, sprPlayerLightAirSideHitbox],
		},
	},
	
	AttacksHeavy : {
		Ground : {
			Up : [sprPlayerHeavyUp, sprPlayerHeavyUpHitbox],
			Down : [sprPlayerHeavyDown, sprPlayerHeavyDownHitbox],
			Side : [sprPlayerHeavySide,sprPlayerHeavySideHitbox],
		},
	},
	
	Taunts : [sprPlayerTaunt1],
}

// Other
attackDir = 0; // 0: Right, 1: Down, 2: Left, 3: Up
attackHitbox = undefined;
spriteEventLog = [];

// Stunning
stunTimer = 0;
stunTimerMax = 120;
stunHeightMultiplier = 1;

function TakeDamage(_dmg) {
	if (targetChar.currentState == CharacterStates.STUN) return;
	if (damageTimer > 0) or (currentState == CharacterStates.BLOCK) return;
	damageTimer = damageTimerMax;
	charHealth -= _dmg;
	var indicator = instance_create_layer(x,y-512,"Instances",objDamageIndicator);
	indicator.depth = -100;
	indicator.valueShown = _dmg;
}

function GetStunned(_dir, _multiplier) {
	if (targetChar.currentState == CharacterStates.STUN) return;
	currentState = CharacterStates.STUN;
	stunHeightMultiplier = _multiplier;
	switch _dir {
		case 1: { // Down
			spriteDir = targetChar.spriteDir;
			xSpeed = (stunBounce/3)*stunHeightMultiplier;
			if (spriteDir == 0) { xSpeed *= -1; }
		} break;
		case 3: { // Up
			spriteDir = targetChar.spriteDir;
			xSpeed = (stunBounce/4)*stunHeightMultiplier;
			if (spriteDir == 0) { xSpeed *= -1; }
		} break;
		default: { // Side
			spriteDir = _dir;
			xSpeed = (stunBounce*6)*stunHeightMultiplier;
			if (_dir == 0) { xSpeed *= -1; }
		}
	}
}

array_push(objGameManager.focusedCharacters,self);