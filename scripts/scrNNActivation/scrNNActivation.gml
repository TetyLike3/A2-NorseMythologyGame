// Neural Network Activation

enum NNActivationType {
	IDENTITY, TANH, SIGMOID, RELU
}

/// @func NNA_Identity(input);
/// @desc Pass-through. Value is left unchanged.
/// @param	{real} input
function NNA_Identity(_input) {
	return _input;
}
/// @func NNA_IdentityDeriv(input);
/// @desc Derivative of Identity.
/// @param	{real} input
function NNA_IdentityDeriv(_input) {
	return 1;
}

/// @func NNA_Tanh(input);
/// @desc Non-linear S-Curve from -1 to 1.
/// @param	{real} input
function NNA_Tanh(_input) {
	return ((2 / (1 + exp(-2 * _input))) - 1);
}
/// @func NNA_TanhDeriv(input);
/// @desc Derivative of Tanh.
/// @param	{real} input
function NNA_TanhDeriv(_input) {
	return (1 - sqr(NNA_Tanh(_input)));
}

/// @func NNA_Sigmoid(input);
/// @desc Similar to Tanh, but ranges from 0 to 1.
/// @param	{real} input
function NNA_Sigmoid(_input) {
	return (1 / (1 + exp(_input)));
}
/// @func NNA_SigmoidDeriv(input);
/// @desc Derivative of Sigmoid.
/// @param	{real} input
function NNA_SigmoidDeriv(_input) {
	_input = NNA_Sigmoid(_input);
	return (_input * (1 - _input));
}

/// @func NNA_Relu(input);
/// @desc Rectified Linear Unit. Acts like a diode in a circuit.
/// @param	{real} input
function NNA_Relu(_input) {
	return max(0, _input);
}
/// @func NNA_ReluDeriv(input);
/// @desc Derivative of RELU.
/// @param	{real} input
function NNA_ReluDeriv(_input) {
	return (_input > 0);
}

global.NNActivationFuncs[NNActivationType.IDENTITY] = NNA_Identity;
global.NNActivationFuncs[NNActivationType.TANH] = NNA_Tanh;
global.NNActivationFuncs[NNActivationType.SIGMOID] = NNA_Sigmoid;
global.NNActivationFuncs[NNActivationType.RELU] = NNA_Relu;

global.NNDerivativeFuncs[NNActivationType.IDENTITY] = NNA_IdentityDeriv;
global.NNDerivativeFuncs[NNActivationType.TANH] = NNA_TanhDeriv;
global.NNDerivativeFuncs[NNActivationType.SIGMOID] = NNA_SigmoidDeriv;
global.NNDerivativeFuncs[NNActivationType.RELU] = NNA_ReluDeriv;