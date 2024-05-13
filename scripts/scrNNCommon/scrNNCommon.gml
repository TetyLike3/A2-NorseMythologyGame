// Neural Network Common

/// @func NN_GetNeuronColour(input);
/// @desc Returns a colour visualising a neuron's input. Used for visualising a network layer.
/// @param	{real} input
function NN_GetNeuronColour(_input) {
	var R = clamp(-min(0,_input)*255,0,255);
	var G = clamp(+max(0,_input)*255,0,255);
	var B = 32;
	return make_color_rgb(R,G,B);
}

/// @func NN_ApproxDeriv(func, input);
/// @desc Returns approximate derivative for a function
/// @param	{function} func
/// @param	{real} input
function NN_ApproxDeriv(_func, _input) {
	var epsilon = math_get_epsilon();
	return (_func(_input+epsilon) - _func(_input-epsilon)) / (epsilon+epsilon);
}