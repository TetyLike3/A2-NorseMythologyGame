// Health
damageTimer = 0;
damageTimerMax = 45;
damageFlashInterval = 15;
uTint = shader_get_uniform(sdrTint,"u_TintColour");


function TakeDamage(dmg) {
	if (damageTimer >  0) return;
	damageTimer = damageTimerMax;
	charHealth -= dmg;
	if (charHealth <= 0) instance_destroy();
}

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

array_push(objGameManager.focusedCharacters,self);