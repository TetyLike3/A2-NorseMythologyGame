event_inherited();

moveSpeed =11;
lightAttackDamage = 8;
heavyAttackDamage = 14;

neuralNetwork = global.BestNetwork;
if is_undefined(neuralNetwork) {
	neuralNetwork = NeuralLoadModel();
	if is_undefined(neuralNetwork) {
		if (room == rmTraining) {
			neuralNetwork = NN_GenerateDefaultNetwork(11, 7);
		} else room_goto(rmTraining);
	}
	//global.BestNetwork = neuralNetwork;
}

aiInputLeft = 0; aiInputRight = 0; aiInputUp = 0; aiInputDown = 0;
aiJumpInput = 0;
aiLightAttackInput = 0; aiHeavyAttackInput = 0;
aiBlockInput = 0; aiGrabInput = 0;

aiBoolConfidence = 0.8;
aiTimeSinceAttack = 0;
aiTimeSinceMove = 0;
aiTimeSinceBlock = 0;
aiMissCount = 0;

aiStepCooldownMax = 5; // Step every 5 frames
aiStepCooldown = irandom(aiStepCooldownMax); // Randomise so work is spread across frames

aiAttackCDMax = 30;
aiAttackCD = aiAttackCDMax;

targetChar = instance_find(objPlayer,0);

function StepNeuralNetwork() {
	if aiStepCooldown > 0 return;
	aiStepCooldown = aiStepCooldownMax;
	
	// Inputs
	if !instance_exists(targetChar) or (targetChar.currentState == CharacterStates.DEAD) {
		aiInputLeft = 0; aiInputRight = 0; aiInputUp = 0; aiInputDown = 0;
		aiJumpInput = 0;
		aiLightAttackInput = 0; aiHeavyAttackInput = 0;
		aiBlockInput = 0; aiGrabInput = 0;
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
}