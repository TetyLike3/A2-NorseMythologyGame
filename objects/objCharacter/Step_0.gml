damageTimer = max(0,damageTimer-1);
staminaRegenTimer = max(0,staminaRegenTimer-1);
stunTimer = max(0,stunTimer-1);
stateChangeCD = max(0,stateChangeCD-1);

if ((x > room_width) or (x < 0)) x = 1856;
if (y > 1440) y = 1056;

if (staminaRegenTimer == 0) {
	staminaLevel = min(100,staminaLevel+staminaRegenRate);
}