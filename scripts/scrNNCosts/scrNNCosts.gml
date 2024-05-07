// Neural Network Costs
enum NNCostTypes {
	MSE
}

/// @func	NNC_Mse(delta, output, target);
/// @desc	Cost function for calculating error from expected values.
/// @desc	Cost is calculated for given delta, which can be back-propagated through the network.
/// @param	{array}		delta		Structure for layers' neurons part for total error, will be updated here.
/// @param	{array}		output		Network prediction for given input (from example)
/// @param	{array}		target		Expected network output values (input-output pair)
function NNC_Mse(_delta, _predictions, _targets) {
	var error = 0;
	var count = array_length(_delta);
	for (var i = 0; i < count; i++) {
		var prediction = _predictions[i];
		var target = _targets[i];
		
		error += sqr(prediction - target) * .5;
		delta[@i] = (prediction - target);
	}
	return error / count;
}

global.NNCostFuncs[NNCostTypes.MSE] = NNC_Mse;