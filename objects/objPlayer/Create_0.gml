event_inherited();

inAir = false;
currentState = PlayerStates.IDLE;
lastState = currentState;

xSpeed = 0;
ySpeed = 0;
canCollideX = true;
canCollideY = true;

moveSpeed = 12;
playerGravity = 0.6;
jumpPower = 18;

spriteDir = 1;

attackHitbox = -1;