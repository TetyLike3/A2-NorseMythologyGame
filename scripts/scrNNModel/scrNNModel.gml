///	@func NeuralModelStringify(target);
/// @desc Creates JSON-string of network, which can be parsed later. 
/// @desc Uses built-in JSON stringifier with dummy-layers to constrain what information is stored, and avoid cyclical references
/// @param {struct.NeuralNetwork} network
function NeuralModelStringify(_network){
	var _size = _network.size;
	var _layers = _network.layers;
	var _dummy = array_create(_size);
	
	for (var i = 0; i < _size; i++) {
		_dummy[i] = new NeuralDummyLayer(_layers[i]);
	}
	
	return json_stringify(_dummy);
}

/// @func NeuralDummyLayer(target);
/// @desc Creates dummy-layer for parsing. Picks references for necessary information
/// @param {layer} target
function NeuralDummyLayer(_layer) constructor {
	type = _layer.type;
	size = _layer.size;
	
	switch (type) {
		case NNLayerType.DENSE: {
			activation = _layer.activation;
			weights = _layer.weights;
			bias = _layer.bias;
		} break;
		default: break;
	}
}



/// @func NeuralModelCopyLayer(destination, source);
/// @desc Copies layer parameters from one to the other.
/// @param {layer} destination
/// @param {layer} source
function NeuralModelCopyLayer(_destination, _source) {
	var _size = _source.size;
	switch (_source.type) {
		case NNLayerType.DENSE: {
			array_copy(_destination.bias, 0, _source.bias, 0, _size);
			var _inputSize = _destination.input.size;
			for (var i = 0; i < _size; i++) {
				array_copy(_destination.weights[i], 0, _source.weights[i], 0, _inputSize);
			}
		}
	}
}

/// @func NeuralModelCopy(destination, source);
/// @desc Copies network parameters from one to the other.
/// @param {struct.NeuralNetwork} destination
/// @param {struct.NeuralNetwork} source
function NeuralModelCopy(_destination, _source) {
	var _size = _destination.size;
	
	for (var i = 0; i < _size; i++) {
		var _layerDest = _destination.layers[i];
		var _layerSrc = _source.layers[i];
		
		if ((_layerDest.type != _layerSrc.type) or (_layerDest.size != _layerSrc.size)) throw("Attempted to copy model data to mismatched structure.");
		
		NeuralModelCopyLayer(_layerDest,_layerSrc);
	}
}


/// @func NeuralModelParse(jsonString, taped);
/// @desc Creates new network from JSON-string
/// @desc Uses dummy-network to copy values over to network
/// @param {string} jsonString
/// @param {boolean} taped
function NeuralModelParse(_stringified, _taped=false) {
	try {
		// Parse JSON
		var _layers = json_parse(_stringified);
		var _size = array_length(_layers);
		
		// Create network
		var _network = _taped
			? new NeuralTapedNetwork()
			: new NeuralNetwork();
		
		// Copy structure & parameters
		for (var i = 0; i < _size; i++) {
			NeuralAddStructure(_network, _layers[i]);
			NeuralModelCopyLayer(_network.layers[i], _layers[i]);
		}
		return _network;
		
	} catch(_err) {
		print("Failed to parse neural model JSON.");
		print(_err);
		show_message("Failed to parse neural model JSON.");
		return undefined;
	}
}

/// @func NeuralAddStructure(network, layer);
/// @desc Adds structural copy of a source layer by using target network builder.
/// @param {struct.NeuralNetwork} network
/// @param {layer} layer
function NeuralAddStructure(_network, _layer) {
	var _add = _network.add;
	var _size = _layer.size;
	
	switch (_layer.type) {
		case NNLayerType.INPUT: return _add.Input(_size);
		case NNLayerType.DENSE: return _add.Dense(_size,_layer.activation);
		default: throw("Unexpected layer type while building network from JSON.");
	}
}