event_inherited();
HandleAIState();

aiStepCooldown--;
aiStepCooldown = max(0, aiStepCooldown-1);
aiTimeSinceAttack++;
aiTimeSinceMove++;
aiAttackCD = max(0, aiAttackCD-1);
if (currentState == CharacterStates.BLOCK) { aiTimeSinceBlock ++; } else aiTimeSinceBlock = 0;