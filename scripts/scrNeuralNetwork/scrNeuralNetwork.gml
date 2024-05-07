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


// Neural Network Layers
enum NNLayerType {
	BASE, INPUT, DENSE
}

/// @func NeuralLayerBase(size);
/// @desc Base structure inherited by every network layer. Has no functionality on it's own.
/// @param	{int} size Count of neurons
function NeuralLayerBase(_size) {
	static type = NNLayerType.BASE;
	static learnable = false;
	static taped = false;
	size = _size;
	input = undefined;
	output = array_create(size,0);
	
	/// @func Forward();
	/// @desc How neuron activities are updated
	static Forward = function() {};
	
	/// @func Destroy();
	/// @desc Destroying the layer, if there are data-structures which needs to be deleted
	static Destroy = function() {};
	
	/// @func Draw(x, y, scale);
	/// @desc Draws a visual representation of the layer's neurons and their activity.
	/// @param	{int} x X position of the visual.
	/// @param	{int} y Y position of the visual.
	/// @param	{int} scale Radius of each neuron.
	/// @param	{int} xSpacing X spacing between neurons.
	/// @param	{int} ySpacing Y spacing between neurons.
	static Draw = function(_x,_y,_scale, _xSpacing, _ySpacing) {
		_y -= _ySpacing * (size/2);
		for (var i = 0; i < size; i++) {
			var value = output[i];
			var colour = NN_GetNeuronColour(value);
			draw_sprite_ext(sprNN_Neuron, 0, _x, _y, _scale, _scale, 0, c_white, 1);
			draw_sprite_ext(sprNN_Neuron, 1, _x, _y, _scale, _scale, 0, colour, 1);
			draw_set_valign(fa_middle); draw_set_halign(fa_center); draw_set_font(fntNN_NeuronValue);
			draw_text(_x,_y,value);
			draw_set_valign(fa_top); draw_set_halign(fa_left); draw_set_font(fntDefault);
			_y += _ySpacing;
		}
	}
}

/// @func NeuralLayerInput(size);
/// @desc Creates a new network layer, intended as the very first layer.
/// @param	{int} size
function NeuralLayerInput(_size) : NeuralLayerBase(_size) constructor {
	static type = NNLayerType.INPUT;
	
	/// @func Forward(input);
	/// @desc Sets value of neuron activity with given array.
	/// @param	{array} input
	static Forward = function(_input) {
		var count =	min(array_length(output), array_length(_input));
		array_copy(output, 0, _input, 0, count);
	}
}

/// @func NeuralTapedInput(size);
/// @desc Creates input-type layer with gradients-structure.
/// @param	{int} size
function NeuralTapedInput(_size) : NeuralLayerInput(_size) constructor {
	static taped = true;
	delta = array_create(size, 0);
	
	/// @func Backward();
	static Backward = function() {
		for (var i = 0; i < size; i++) {
			delta[@i] = 0;
		}
	}
}

/// @func NeuralLayerDense(input, size, activation);
/// @desc Creates new neural network layer, which is "fully connected" to previous layer
/// @param	{layer} input Neural network layer
/// @param	{int} size Count of neurons
/// @param	{enum} activation Enum identifier for activation function.
function NeuralLayerDense(_input, _size, _activation) : NeuralLayerBase(_size) constructor {
	static type = NNLayerType.DENSE;
	static learnable = true;
	input = _input;
	activation = _activation;
	
	activity = array_create(size, 0);
	bias = array_create(size, 0);
	weights = array_create(size);
	
	for (var i = 0; i < size; i++) {
		bias[@i] = random_range(-.2,.2);
		weights[@i] = array_create(input.size, 0);
		for (var j = 0; j < size; j++) {
			weights[@i][@j] = random_range(-.5,.5);
		}
	}
	
	/// @func Forward();
	/// @desc Propagates signal forward, calculates neuron activity as weighted sum and then applies activation function.
	static Forward = function() {
		var Activation = global.NNActivationFuncs[activation];
		for (var i = 0; i < size; i++) {
			var weightedSum = 0;
			for (var j = 0; j < input.size; j++) {
				weightedSum += input.output[j] * weights[i][j];
			}
			activity[@i] = weightedSum;
			
			output[@i] = Activation(weightedSum + bias[i]);
		}
	}
}

/// @func NeuralTapedDense(input, size, activation);
/// @desc Creates dense-type layer with gradients-structures.
/// @param	{layer} input Neural network layer.
/// @param	{int} size Count of neurons.
/// @param	{enum} activation Enum identifier for activation function.
function NeuralTapedDense(_input, _size, _activation) : NeuralLayerDense(_input, _size, _activation) constructor {
	static taped = true;
	session = 0;
	delta = array_create(size, 0);
	
	tapeBias = array_create(size, 0);
	tapeWeights = array_create(size);
	
	for (var i = 0; i < size; i++) {
		tapeWeights[@i] = array_create(input.size, 0);
	}
	
	/// @func Backward();
	/// @desc Passes gradient information to the next layer and updates gradient-tapes.
	static Backward = function() {
		var Derivative = global.NNDerivativeFuncs[activation];
		
		for (var i = 0; i < size; i++) {
			var gradient = delta[i] * Derivative(activity[i]);
			
			for (var j = 0; j < input.size; j++) {
				input.delta[@j] += weights[i][j] * gradient;
				tapeWeights[@i][@j] += input.output[j] * gradient;
			}
			
			tapeBias[@i] += gradient;
			delta[@i] = 0;
		}
		session++;
	}
	
	/// @func Apply(learnRate);
	/// @desc Uses gradient descent to update learnable parameters. 
	/// @param {real} learnRate
	static Apply = function(_learnRate) {
		for (var i = 0; i < size; i++) {
			bias[@i] += -_learnRate * tapeBias[i] / session;
			tapeBias[@i] = 0;
		}
		
		for (var i = 0; i < size; i++) {
			for (var j = 0; j < input.size; j++) {
				weights[@i][@j] += -_learnRate * tapeWeights[i][j] / session;
				tapeWeights[@i][@j] = 0;
			}
		}
		
		session = 0;
	}
}

/// @func NeuralBuilder(target);
/// @desc Helper struct for adding new layers to a neural network.
/// @param	{Struct.NeuralNetwork} target
function NeuralBuilder(_target) constructor {
	nn = _target;
	
	static ADD = function(_layer) {
		array_push(nn.layers, _layer);
		nn.last = _layer;
		nn.size = array_length(nn.layers);
		return _layer;
	}
	
	static Input = function(_size) {
		if (!is_undefined(nn.first)) {
			throw("Cannot overwrite existing input layer");
		}
		nn.first = (nn.taped)
			? ADD(new NeuralTapedInput(_size))
			: ADD(new NeuralLayerInput(_size));
			
		return nn.first;
	}
	
	static Dense = function(_size, _activation) {
		 return (nn.taped)
			? ADD(new NeuralTapedDense(nn.last, _size, _activation))
			: ADD(new NeuralLayerDense(nn.last, _size, _activation));
	}
}

/// @func NeuralNetwork();
/// @desc Creates base structure for a neural network.
function NeuralNetwork() constructor {
	static taped = false;
	layers = [];
	size = 0;
	first = undefined;
	last = undefined;
	add = new NeuralBuilder(self);
	
	// Pass in initial inputs for NN
	/// @func	Input(input);
	/// @desc	Updates neurons' activity of first layer
	/// @param	{any}	input	Values to feed into the network.
	static Input = function(_input) {
		first.Forward(_input);
	}
	
	// Process the inputs
	/// @func	Forward(input);
	/// @desc	Propagates signal from first layer towards last layer.
	/// @param	{any}	input	[optional] updates first layer activity by given argument. Otherwise skipped.
	static Forward = function(_input) {
		if (!is_undefined(_input)) Input(_input);
		
		for (var i = 1; i < size; i++) {
			layers[i].Forward();
		}
		
		// Return outputs
		return last.output;
	}
	
	/// @func	Destroy();
	/// @desc	Destroys network layers.
	static Destroy = function() {
		for (var i = 0; i < size; i++) {
			layers[i].Destroy();
		}
	}
	
	/// @func Draw(x, y, scale, xSpacing, ySpacing);
	/// @desc Visualizes network by drawing the layers. Sets x-origin at the middle of network.
	/// @param	{int} x
	/// @param	{int} y
	/// @param	{int} scale
	/// @param	{int} xSpacing X spacing between neurons.
	/// @param	{int} ySpacing Y spacing between neurons.
	static Draw = function(_x,_y,_scale, _xSpacing, _ySpacing) {
		_x -= _xSpacing * (size/2);
		for (var i = 0; i < size; i++) {
			layers[i].Draw(_x,_y,_scale, _xSpacing, _ySpacing);
			_x += _xSpacing;
		}
	}
}


/// @func NeuralTapedNetwork();
/// @desc Creates a neural network with gradients-structure for layers.
function NeuralTapedNetwork() : NeuralNetwork() constructor {
	static taped = true;
	error = 0;
	session = 0;
	
	/// @func Cost(targets, costFunction);
	/// @desc Calculates error for last layer/prediction by comparing to the given target values
	/// @param	{array} targets			Values that the network should have returned
	/// @param	{enum}	costFunction	(optional) Method of calculating error from targets. Default is MSE.
	static Cost = function(_targets, _costFuncType = NNCostTypes.MSE) {
		var costFunc = global.NNCostFuncs[_costFuncType];
		error = costFunc(last.delta, last.output, _targets);
		return error;
	}
	
	/// @func Backward();
	/// @desc Backpropagates previously calculated error from last layer towards the first one.
	static Backward = function() {
		for (var i = size - 1; i > 0; i--) {
			layers[i].Backward();
		}
		session++;
		
		return first.delta;
	}
	
	/// @func Apply(learnRate);
	/// @desc Uses average errors from several examples to update learnable parameters.
	/// @param	{real} learnRate How large steps are taken. Too little slows learning, but too much overshoots local minima.
	static Apply = function(_learnRate) {
		for (var i = 1; i < size; i++) {
			if (layers[i].learnable) {
				layers[i].Apply(_learnRate);
			}
		}
		session = 0;
	}
	
	static BaseDestroy = Destroy;
	static Destroy = function() {
		BaseDestroy();
		error = 0;
		session = 0;
	}
}

// Neural Network Training

/// @func	NN_GenerateDefaultNetwork(inputCount, outputCount);
/// @desc	Creates a general neural network
/// @param	{real} inputCount How many input nodes the network will have
/// @param	{real} outputCount How many output nodes the network will have
function NN_GenerateDefaultNetwork(_inputCount, _outputCount) {
	var newNetwork = new NeuralTapedNetwork();
	newNetwork.add.Input(_inputCount);
	newNetwork.add.Dense(_inputCount*2, NNActivationType.IDENTITY);
	newNetwork.add.Dense(_inputCount*3, NNActivationType.TANH);
	newNetwork.add.Dense((_inputCount*3)+2, NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*5), NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*4)+2, NNActivationType.TANH);
	newNetwork.add.Dense((_outputCount*3)+2, NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*2)+3, NNActivationType.TANH);
	newNetwork.add.Dense((_outputCount*2)+1, NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*2), NNActivationType.IDENTITY);
	newNetwork.add.Dense(_outputCount, NNActivationType.IDENTITY);
	
	return newNetwork;
}

/// @func	NN_GenerateDefaultNetworks(count, inputCount, outputCount);
/// @desc	Creates multiple neural networks
/// @param	{real} count How many neural networks to generate
/// @param	{real} inputCount How many input nodes each network will have
/// @param	{real} outputCount How many output nodes each network will have
function NN_GenerateDefaultNetworks(_count, _inputCount, _outputCount) {
	var networks = [];
	for (var i = 0; i < _count; i++) {
		networks[i] = NN_GenerateDefaultNetwork(_inputCount,_outputCount);
	}
	return networks;
}