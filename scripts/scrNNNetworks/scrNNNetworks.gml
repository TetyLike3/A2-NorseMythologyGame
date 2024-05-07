// Neural Network Networks

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