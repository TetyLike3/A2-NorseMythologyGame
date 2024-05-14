event_inherited();

moveSpeed = 8;
lightAttackDamage = 8;
heavyAttackDamage = 14;

neuralNetwork = global.BestNetwork;
if is_undefined(neuralNetwork) {
	neuralNetwork = NeuralLoadModel();
	if is_undefined(neuralNetwork) room_goto(rmTraining);
	global.BestNetwork = neuralNetwork;
}

aiXInput = 0; aiJumpInput = 0;
aiLightAttackInput = 0; aiHeavyAttackInput = 0;
aiBlockInput = 0; aiGrabInput = 0;

aiBoolConfidence = 0.8;
aiTimeSinceAttack = 0;
aiTimeSinceMove = 0;
aiTimeAgainstWall = 0;
aiTimeInBlock = 0;
aiMissCount = 0;

aiStepCooldownMax = 5; // Step every 5 frames
aiStepCooldown = 0;

aiAttackCDMax = 30;
aiAttackCD = aiAttackCDMax;

function StepNeuralNetwork() {
	if aiStepCooldown > 0 return;
	aiStepCooldown = aiStepCooldownMax;
	
	// Inputs
	if !instance_exists(targetChar) or (targetChar.currentState == CharacterStates.DEAD) {
		aiXInput = 0; aiJumpInput = 0;
		aiLightAttackInput = 0; aiHeavyAttackInput = 0;
		aiBlockInput = 0; aiGrabInput = 0;
		return;
	}
	var inputs = [];
	inputs[0] = 1;
	inputs[1] = 0;
	inputs[2] = x/room_width;
	inputs[3] = charHealth/100;
	inputs[4] = currentState/7;
	inputs[5] = spriteDir;
	inputs[6] = min(aiAttackCD/aiAttackCDMax,1);
	inputs[7] = stunTimer/stunTimerMax;
	inputs[8] = min((distance_to_object(objPlayer)/room_width)*120,1);
	inputs[9] = objPlayer.charHealth/100;
	inputs[10] = objPlayer.currentState/7;
	
	neuralNetwork.Input(inputs);
	
	// Outputs
	var outputs = neuralNetwork.Forward();
	aiXInput = (abs(outputs[0]) > INPUT_DEADZONE) ? clamp(outputs[0],-1,1) : 0;
	aiJumpInput = outputs[1] > aiBoolConfidence;
	aiLightAttackInput = outputs[2] > aiBoolConfidence;
	aiHeavyAttackInput = outputs[3] > aiBoolConfidence;
	aiBlockInput = outputs[4] > aiBoolConfidence;
	aiGrabInput = outputs[5] > aiBoolConfidence;
}