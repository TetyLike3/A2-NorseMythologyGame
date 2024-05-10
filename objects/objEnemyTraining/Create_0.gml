 event_inherited();

moveSpeed = 8;
lightAttackDamage = 20;
heavyAttackDamage = 40;

neuralNetwork = NN_GenerateDefaultNetwork(10, 5);
aiXInput = 0; aiJumpInput = 0;
aiLightAttackInput = 0; aiHeavyAttackInput = 0;
aiBlockInput = 0;

aiFitness = 0;
aiFitnessUpdateTimerMax = 10;
aiFitnessUpdateTimer = aiFitnessUpdateTimerMax;
aiBoolConfidence = 0.02;
aiLocalEnemy = undefined;
aiTimeSinceAttack = 0;
aiTimeSinceMove = 0;
aiTimeAgainstWall = 0;
aiMissCount = 0;

aiStepCooldownMax = 5; // Step every 5 frames
aiStepCooldown = 0;

aiAttackCDMax = 30;
aiAttackCD = aiAttackCDMax;

function Restart() {
	x = xstart;
	y = ystart;
	aiFitness = 0;
	charToFace = aiLocalEnemy;
	aiBoolConfidence = lerp(aiBoolConfidence,0.8,0.1);
	aiTimeSinceMove = 0;
	aiTimeSinceAttack = 0;
	aiTimeAgainstWall = 0;
	aiMissCount = 0;
	charHealth = 100;
	currentState = CharacterStates.IDLE;
}

function UpdateFitness() {
	if (aiFitnessUpdateTimer > 0) return;
	aiFitnessUpdateTimer = aiFitnessUpdateTimerMax;
	
	if !instance_exists(aiLocalEnemy) or (aiLocalEnemy.currentState == CharacterStates.DEAD) {
		aiFitness += ((objGeneticControl.count-objGeneticControl.remainingCounter));
		return;
	}
	
	aiFitness += (charHealth/100); // Reward for maintaining health
	if (abs(xSpeed) == 0) {
		aiFitness -= min((1 + (aiTimeSinceMove)/100)^1.3,4); // Punish for standing still
	} else {
		aiFitness += (xSpeed^1.2)/10; // Reward for moving faster
	}
	
	if (attackHitbox) {
		var hitCount = array_length(attackHitbox.collidedWith);
		if (hitCount > 0) {
			aiFitness += (hitCount)^1.1; // Reward for having active hitbox with collision history
		} else { aiFitness -= (aiMissCount^1.1); } // Punish for missing an attack
	}
	
	aiFitness += ((100-aiLocalEnemy.charHealth)^1.3)/100; // Reward for low target health
	aiFitness += clamp((768-distance_to_object(aiLocalEnemy))/512,-1,2); // Reward (or punish) based on distance from target
	aiFitness -= (aiTimeSinceAttack*0.01)^1.02; // Punish for not attacking frequently
	//aiFitness -= clamp((64+distance_to_point(room_width/2,y))/64,-1,1); // Encourage AI to stay in centre of room
	if getWallCollision() {
		aiFitness -= aiTimeAgainstWall^1.1; // Punish AI for waiting against a wall
	}
	
	// Encourages AI to make a new move if their fitness is increased from this limit
	aiFitness = max(aiFitness,objGeneticControl.fitnessLowerLimit);
}

function StepNeuralNetwork() {
	if aiStepCooldown > 0 return;
	aiStepCooldown = aiStepCooldownMax;
	
	// Inputs
	if !instance_exists(aiLocalEnemy) or (aiLocalEnemy.currentState == CharacterStates.DEAD) {
		aiXInput = 0; aiJumpInput = 0;
		aiLightAttackInput = 0; aiHeavyAttackInput = 0;
		aiBlockInput = 0;
		UpdateFitness();
		return;
	}
	var inputs = [];
	inputs[0] = clamp(aiFitness/(objGeneticControl.bestFitness+1),-1,1);
	inputs[1] = x/room_width;
	inputs[2] = charHealth/100;
	inputs[3] = currentState/7;
	inputs[4] = spriteDir;
	inputs[5] = min(aiAttackCD/aiAttackCDMax,1);
	inputs[6] = stunTimer/stunTimerMax;
	inputs[7] = min((distance_to_object(aiLocalEnemy)/room_width)*120,1);
	inputs[8] = aiLocalEnemy.charHealth/100;
	inputs[9] = aiLocalEnemy.currentState/7;
	
	neuralNetwork.Input(inputs);
	
	// Outputs
	var outputs = neuralNetwork.Forward();
	aiXInput = (abs(outputs[0]) > 0.2) ? clamp(outputs[0],-1,1) : 0;
	//aiXInput = outputs[0];
	aiJumpInput = outputs[1] > aiBoolConfidence;
	aiLightAttackInput = outputs[2] > aiBoolConfidence;
	aiHeavyAttackInput = outputs[3] > aiBoolConfidence;
	aiBlockInput = outputs[4] > aiBoolConfidence;
	
	UpdateFitness();
}

Restart();