if (objGameManager.roundEnded) {
	if (!objGameManager.playerWon) {
		if (sprite_index != spriteIndices.Taunts[0]) {
			changeSprite(spriteIndices.Taunts[0]);
		}
	} else {
		changeSprite(spriteIndices.Lying);
	}
	executeGroundCollision();
	return;
}

event_inherited();
HandleAIState();

aiStepCooldown--;
aiStepCooldown = max(0, aiStepCooldown-1);
aiTimeSinceAttack++;
aiTimeSinceMove++;
aiAttackCD = max(0, aiAttackCD-1);
if (currentState == CharacterStates.BLOCK) { aiTimeSinceBlock ++; } else aiTimeSinceBlock = 0;