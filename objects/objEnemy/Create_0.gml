event_inherited();

moveSpeed = 8;
lightAttackDamage = 20;
heavyAttackDamage = 40;

neuralNetwork = global.BestNetwork;
if is_undefined(neuralNetwork) {
	var stringified = clipboard_get_text();
	neuralNetwork = NeuralModelParse(stringified, true);
}

aiXInput = 0; aiJumpInput = 0;
aiLightAttackInput = 0; aiHeavyAttackInput = 0;
aiBlockInput = 0;

aiBoolConfidence = 0.8;
aiTimeSinceAttack = 0;
aiTimeSinceMove = 0;
aiTimeAgainstWall = 0;
aiMissCount = 0;

aiStepCooldownMax = 5; // Step every 5 frames
aiStepCooldown = 0;

aiAttackCDMax = 30;
aiAttackCD = aiAttackCDMax;

charToFace = instance_find(objPlayer,0);

function StepNeuralNetwork() {
	if aiStepCooldown > 0 return;
	aiStepCooldown = aiStepCooldownMax;
	
	// Inputs
	if !instance_exists(charToFace) {
		aiXInput = 0; aiJumpInput = 0;
		aiLightAttackInput = 0; aiHeavyAttackInput = 0;
		aiBlockInput = 0;
		return;
	}
	var inputs = [];
	inputs[0] = 1;
	inputs[1] = x/room_width;
	inputs[2] = charHealth/100;
	inputs[3] = currentState/7;
	inputs[4] = spriteDir;
	inputs[5] = min(aiAttackCD/aiAttackCDMax,1);
	inputs[6] = stunTimer/stunTimerMax;
	inputs[7] = min((distance_to_object(objPlayer)/room_width)*120,1);
	inputs[8] = objPlayer.charHealth/100;
	inputs[9] = objPlayer.currentState/7;
	
	neuralNetwork.Input(inputs);
	
	// Outputs
	var outputs = neuralNetwork.Forward();
	aiXInput = (abs(outputs[0]) > 0.2) ? clamp(outputs[0],-1,1) : 0;
	//aiXInput = outputs[0];
	aiJumpInput = outputs[1] > aiBoolConfidence;
	aiLightAttackInput = outputs[2] > aiBoolConfidence;
	aiHeavyAttackInput = outputs[3] > aiBoolConfidence;
	aiBlockInput = outputs[4] > aiBoolConfidence;
}