// Health
charHealth = charHealthMax;
damageTimer = 0;
damageTimerMax = 45;
damageFlashInterval = 15;
uTint = shader_get_uniform(sdrTint,"u_TintColour");

// Physics
moveSpeed = 12;
jumpPower = 18;

canJump = false;
currentState = CharacterStates.IDLE;
lastState = currentState;
stateChangeCDMax = 5;
stateChangeCD = 0;

xSpeed = 0;
ySpeed = 0;
canCollideX = true;
canCollideY = true;

// Visual
spriteDir = 1;
charToFace = -1;

// Other
attackHitbox = undefined;
spriteEventLog = [];

// Stunning
stunTimer = 0;
stunTimerMax = 120;

function TakeDamage(dmg) {
	if (damageTimer > 0) or (currentState == CharacterStates.BLOCK) return;
	damageTimer = damageTimerMax;
	charHealth -= dmg;
	currentState = CharacterStates.STUN;
}

array_push(objGameManager.focusedCharacters,self);