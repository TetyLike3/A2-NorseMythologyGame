event_inherited();

moveSpeed = 8;

neuralNetwork = NN_GenerateDefaultNetwork(7, 4);
aiShouldTrain = false;
aiXInput = 0; aiJumpInput = 0;
aiLightAttackInput = 0;
aiBlockInput = 0;

function StepNeuralNetwork() {
	// Inputs
	var inputs = [];
	inputs[0] = charHealth/100;
	inputs[1] = currentState/7;
	inputs[2] = min((distance_to_object(objPlayer)/room_width)*4,1);
	inputs[3] = objPlayer.currentState/7;
	inputs[4] = damageTimer/damageTimerMax;
	inputs[5] = stunTimer/stunTimerMax;
	inputs[6] = clamp(ySpeed/16,-1,1);
	
	neuralNetwork.Input(inputs);
	
	// Outputs
	outputs = neuralNetwork.Forward();
	aiXInput = (abs(outputs[0]) > 0.1 and outputs[0]) or 0;
	aiJumpInput = outputs[1] > 0.8;
	aiLightAttackInput = outputs[2] > 0.8;
	aiBlockInput = outputs[3] > 0.8;
}