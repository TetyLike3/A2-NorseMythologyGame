event_inherited();

aiFitness = 0;
aiLastFitness = 0;
aiFitnessDelta = 0;
aiFitnessUpdateTimerMax = 10;
aiFitnessUpdateTimer = aiFitnessUpdateTimerMax;

function Restart() {
	x = xstart;
	y = ystart;
	aiFitness = 0;
	aiLastFitness = 0;
	aiFitnessDelta = 0;
	aiBoolConfidence = lerp(aiBoolConfidence,0.8,0.1);
	aiTimeSinceMove = 0;
	aiTimeSinceAttack = 0;
	aiTimeSinceBlock = 0;
	aiMissCount = 0;
	
	charHealth = charHealthMax;
	currentState = CharacterStates.IDLE;
}

function UpdateFitness() {
	if (aiFitnessUpdateTimer > 0) return;
	aiFitnessUpdateTimer = aiFitnessUpdateTimerMax;
	
	aiFitnessDelta = aiFitness-aiLastFitness;
	aiLastFitness = aiFitness;
	
	aiFitness += clamp((.5-(point_distance(x,y,room_width/2,y)/(room_width/2)))*40,-40,4) // Reward AI for staying near centre

	if !instance_exists(targetChar) or (targetChar.currentState == CharacterStates.DEAD) {
		aiFitness += ((objGeneticControl.count-objGeneticControl.remainingCounter));
		return;
	}
	
	aiFitness += (charHealth/100); // Reward for maintaining health
	if (abs(xSpeed) == 0) {
		aiFitness -= min((1 + (aiTimeSinceMove)/100)^1.3,4); // Punish for standing still
	} else {
		aiFitness += (xSpeed^1.2)/10; // Reward for moving faster
	}
	if (instance_exists(attackHitbox)) {
		var hitCount = array_length(attackHitbox.collidedWith);
		if (hitCount > 0) {
			aiFitness += (hitCount)^1.1; // Reward for having active hitbox with collision history
		} else { aiFitness -= (aiMissCount^1.1); } // Punish for missing an attack
	}
	aiFitness += ((100-targetChar.charHealth)^1.3)/100; // Reward for low target health
	aiFitness += clamp((768-distance_to_object(targetChar))/512,-1,2); // Reward (or punish) based on distance from target
	aiFitness -= (aiTimeSinceAttack/100)^1.01; // Punish for not attacking frequently
	
	// Reward for successfully grabbing (or punish for missing)
	if (targetChar.currentState == CharacterStates.GRABBED) {
		aiFitness += 12;
	} else if (currentState == CharacterStates.GRABBING) {
		aiFitness -= 8;
	}
	
	if (targetChar.currentState == CharacterStates.BLOCK) {
		aiFitness -= 4;
	}
	
	// Reward for not holding block (to an extent)
	aiFitness += clamp((aiTimeSinceBlock/100)^1.02,0,1);
	
	// Reward AI for maintaining high stamina
	aiFitness += clamp((staminaLevel/100)^1.02,0,1);
	
	// Encourages AI to make a new move if their fitness is increased from this limit
	aiFitness = max(aiFitness,objGeneticControl.fitnessLowerLimit);
}

function StepNeuralNetwork() {
	if aiStepCooldown > 0 return;
	aiStepCooldown = aiStepCooldownMax;
	
	// Inputs
	if !instance_exists(targetChar) or (targetChar.currentState == CharacterStates.DEAD) {
		aiInputLeft = 0; aiInputRight = 0; aiInputUp = 0; aiInputDown = 0;
		aiJumpInput = 0;
		aiLightAttackInput = 0; aiHeavyAttackInput = 0;
		aiBlockInput = 0; aiGrabInput = 0;
		UpdateFitness();
		return;
	}
	var inputs = [];
	inputs[0] = x/room_width;
	inputs[1] = charHealth/100;
	inputs[2] = staminaLevel/100;
	inputs[3] = currentState/7;
	inputs[4] = spriteDir;
	inputs[5] = min(aiAttackCD/aiAttackCDMax,1);
	inputs[6] = stunTimer/stunTimerMax;
	inputs[7] = min((distance_to_object(targetChar)/room_width)*120,1);
	inputs[8] = targetChar.charHealth/100;
	inputs[9] = targetChar.staminaLevel/100;
	inputs[10] = targetChar.currentState/7;
	
	neuralNetwork.Input(inputs);
	
	// Outputs
	var outputs = neuralNetwork.Forward();
	
	aiInputLeft = (outputs[0] < -INPUT_DEADZONE) ? clamp(outputs[0],-1,0) : 0;
	aiInputRight = (outputs[0] > INPUT_DEADZONE) ? clamp(outputs[0],0,1) : 0;
	aiInputUp = (outputs[1] > INPUT_DEADZONE) ? clamp(outputs[1],0,1) : 0;
	aiInputDown = (outputs[1] < -INPUT_DEADZONE) ? clamp(outputs[1],-1,0) : 0;
	
	inputVector[0] = aiInputLeft + aiInputRight;
	inputVector[1] = aiInputDown + aiInputUp;
	
	aiJumpInput = outputs[2] > aiBoolConfidence;
	aiLightAttackInput = outputs[3] > aiBoolConfidence;
	aiHeavyAttackInput = outputs[4] > aiBoolConfidence;
	aiBlockInput = outputs[5] > aiBoolConfidence;
	aiGrabInput = outputs[6] > aiBoolConfidence;
	
	UpdateFitness();
}

Restart();