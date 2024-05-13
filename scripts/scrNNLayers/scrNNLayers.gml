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
			//draw_set_valign(fa_middle); draw_set_halign(fa_center); draw_set_font(fntNN_NeuronValue);
			//draw_text(_x,_y,value);
			//draw_set_valign(fa_top); draw_set_halign(fa_left); draw_set_font(fntDefault);
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