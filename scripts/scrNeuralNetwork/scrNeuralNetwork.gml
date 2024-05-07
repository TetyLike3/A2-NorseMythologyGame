// Neural Network Activation

enum NNActivationType {
	IDENTITY, TANH, SIGMOID, RELU
}

// Pass-through.
function NNA_Identity(_input) {
	return _input;
}

// Non-linear S-Curve from -1 to 1.
function NNA_Tanh(_input) {
	return ((2 / (1 + exp(-2 * input))) - 1);
}

// Similar to Tanh, but ranges from 0 to 1.
function NNA_Sigmoid(_input) {
	return (1 / (1 + exp(_input)));
}

// Rectified linear unit. Not "balanced" like Tanh or Sigmoid.
function NNA_Relu(_input) {
	return max(0, _input);
}

global.NNActivationFuncs[NNActivationType.IDENTITY] = NNA_Identity;
global.NNActivationFuncs[NNActivationType.TANH] = NNA_Tanh;
global.NNActivationFuncs[NNActivationType.SIGMOID] = NNA_Sigmoid;
global.NNActivationFuncs[NNActivationType.RELU] = NNA_Relu;



// Neural Network Layers
enum NNLayerType {
	BASE, INPUT, DENSE
}

function NeuralLayerBase(_size) {
	static type = NNLayerType.BASE;
	size = _size;
	input = undefined;
	output = array_create(size,0);
	
	static Forward = function() {};
	
	static Destroy = function() {};
}

function NeuralLayerInput(_size) : NeuralLayerBase(_size) constructor {
	static type = NNLayerType.INPUT;
	
	static Forward = function(_input) {
		var count =	min(array_length(output), array_length(_input));
		array_copy(output, 0, _input, 0, count);
	}
}

function NeuralLayerDense(_input, _size, _activation) : NeuralLayerBase(_size) constructor {
	static type = NNLayerType.DENSE;
	input = _input;
	activation = _activation;
	
	bias = array_create(size, 0);
	weights = array_create(size);
	
	for (var i = 0; i < size; i++) {
		bias[@i] = random_range(-.2,.2);
		weights[@i] = array_create(input.size, 0);
		for (var j = 0; j < size; j++) {
			weights[@i][@j] = random_range(-.5,.5);
		}
	}
	
	static Forward = function() {
		var Activation = global.NNActivationFuncs[activation];
		for (var i = 0; i < size; i++) {
			var weightedSum = 0;
			for (var j = 0; j < input.size; j++) {
				weightedSum += input.output[j] * weights[i][j];
			}
			output[@i] = Activation(weightedSum + bias[i]);
		}
	}
}

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
		nn.first = ADD(new NeuralLayerInput(_size));
		return nn.first;
	}
	
	static Dense = function(_size, _activation) {
		 return ADD(new NeuralLayerDense(nn.last, _size, _activation));
	}
}


function NeuralNetwork() constructor {
	layers = [];
	size = 0;
	first = undefined;
	last = undefined;
	add = new NeuralBuilder(self);
	
	// Pass in initial inputs for NN
	static Input = function(_input) {
		first.Forward(_input);
	}
	
	// Process the inputs
	static Forward = function(_input) {
		if (!is_undefined(_input)) Input(_input);
		
		for (var i = 1; i < size; i++) {
			layers[i].Forward();
		}
		
		// Return outputs
		return last.output;
	}
}

// Neural Network Training

function GenerateDefaultNetworks(_count, _inputCount, _outputCount) {
	var networks = [];
	for (var i = 0; i < _count; i++) {
		var newNetwork = new NeuralNetwork();
		newNetwork.add.Input(_inputCount);
		newNetwork.add.Dense(_outputCount*5, NNActivationType.TANH);
		newNetwork.add.Dense(_outputCount*2, NNActivationType.RELU);
		newNetwork.add.Dense(_outputCount, NNActivationType.SIGMOID);
		
		networks[i] = newNetwork;
		
	}
	return networks;
}