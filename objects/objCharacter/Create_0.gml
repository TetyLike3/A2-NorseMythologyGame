// Health
damageTimer = 0;
damageTimerMax = 45;
damageFlashInterval = 15;
uTint = shader_get_uniform(sdrTint,"u_TintColour");

//Healthbar
HealthBarHeight=128;
HealthBarWidth=498;
charHealthMax=charHealth
// Physics
moveSpeed = 12;
jumpPower = 18;

inAir = false;
currentState = CharacterStates.IDLE;
lastState = currentState;

xSpeed = 0;
ySpeed = 0;
canCollideX = true;
canCollideY = true;

// Visual
spriteDir = 1;
charToFace = -1;

// Other
attackHitbox = -1;

// Stunning
stunTimer = 0;
stunTimerMax = 120;

function TakeDamage(dmg) {
	if (damageTimer >  0) or (currentState == CharacterStates.BLOCK) return;
	damageTimer = damageTimerMax;
	charHealth -= dmg;
	if (charHealth <= 0) instance_destroy();
	currentState = CharacterStates.STUN;
}

array_push(objGameManager.focusedCharacters,self);