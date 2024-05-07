event_inherited();

moveSpeed = 8;

neuralNetwork = NN_GenerateDefaultNetwork(8, 4);
aiShouldTrain = false;
aiXInput = 0; aiJumpInput = 0;
aiLightAttackInput = 0;
aiBlockInput = 0;

aiFitness = 0;
aiFitnessUpdateTimerMax = 10;
aiFitnessUpdateTimer = aiFitnessUpdateTimerMax;
aiLocalEnemy = undefined;

function Restart() {
	x = 1856;
	y = 1056;
	aiFitness = 0;
	if aiLocalEnemy instance_destroy(aiLocalEnemy);
	aiLocalEnemy = instance_create_layer(1280,1216,"Instances",objPlayer);
	charToFace = aiLocalEnemy;
}

function UpdateFitness(_inputs) {
	if (aiFitnessUpdateTimer > 0) return;
	aiFitnessUpdateTimer = aiFitnessUpdateTimerMax;
	
	// Fitness
	aiFitness += (charHealth/10); // Reward for maintaining health
	if (abs(xSpeed) > 4) { aiFitness -= 700; } // Punish for standing still (or moving slow)
	aiFitness += (100-aiLocalEnemy.charHealth); // Reward for low enemy health
	aiFitness += (7-abs(xSpeed))*100; // Reward for moving (fast)
	
	if (charHealth > 70) {
		if (_inputs[2] < 1) aiFitness += 240; // Reward for keeping close distance to enemy at high health
	}
}

function StepNeuralNetwork() {
	// Inputs
	var inputs = [];
	inputs[0] = charHealth/100;
	inputs[1] = currentState/7;
	inputs[2] = min((distance_to_object(aiLocalEnemy)/room_width)*4,1);
	inputs[3] = aiLocalEnemy.charHealth/100;
	inputs[4] = aiLocalEnemy.currentState/7;
	inputs[5] = damageTimer/damageTimerMax;
	inputs[6] = stunTimer/stunTimerMax;
	inputs[7] = clamp(ySpeed/16,-1,1);
	
	neuralNetwork.Input(inputs);
	
	// Outputs
	outputs = neuralNetwork.Forward();
	//aiXInput = ((abs(outputs[0]) > 0.1) and outputs[0]) or 0;
	aiXInput = outputs[0];
	aiJumpInput = outputs[1] > 0.8;
	aiLightAttackInput = outputs[2] > 0.8;
	aiBlockInput = outputs[3] > 0.8;
	
	UpdateFitness(inputs);
}

Restart();