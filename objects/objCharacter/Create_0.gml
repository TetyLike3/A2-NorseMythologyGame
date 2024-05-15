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

stunBounceMax = 3;
stunBounce = 0;

// Visual
spriteDir = 1;

// Other
attackHitbox = undefined;
spriteEventLog = [];

// Stunning
stunTimer = 0;
stunTimerMax = 120;

function TakeDamage(_dmg) {
	if (targetChar.currentState == CharacterStates.STUN) return;
	if (damageTimer > 0) or (currentState == CharacterStates.BLOCK) return;
	damageTimer = damageTimerMax;
	charHealth -= _dmg;
	var indicator = instance_create_layer(x,y-512,"Instances",objDamageIndicator);
	indicator.depth = -100;
	indicator.valueShown = _dmg;
}

function GetStunned(_dir, _height) {
	if (targetChar.currentState == CharacterStates.STUN) return;
	currentState = CharacterStates.STUN;
	spriteDir = _dir;
	ySpeed = -_height;
	xSpeed = _height/2;
	if (_dir == 0) { xSpeed *= -1; }
}

array_push(objGameManager.focusedCharacters,self);