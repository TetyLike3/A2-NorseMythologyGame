damageTimer = 0;
damageTimerMax = 120;
damageFlashInterval = 40;
uTint = shader_get_uniform(sdrTint,"u_TintColour");

charToFace = -1;

function TakeDamage(dmg) {
	if (damageTimer >  0) return;
	damageTimer = damageTimerMax;
	charHealth -= dmg;
	if (charHealth <= 0) instance_destroy();
}

array_push(objGameManager.focusedCharacters,self);