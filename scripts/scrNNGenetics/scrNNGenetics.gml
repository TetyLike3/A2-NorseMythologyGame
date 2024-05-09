// Neural Network Genetics

/// @func NeuralGeneticSelection(population);
/// @desc Sorts population by their fitness, assumes higher fitness is better.
/// @param {array} population Array of structs/instances.
function NeuralGeneticSelection(_population) {
	array_sort(_population, function(A, B) {
		return B.aiFitness - A.aiFitness;
	});
}

///	@func NeuralGeneticLayerCrossover(child, parentA, parentB);
/// @desc Modifies child/target layer by copying parts from parents.
/// @desc Assumes that layers have same architeture (type, size etc.).
/// @param {layer} child Target layer where modifications are done
/// @param {layer} parentA 
/// @param {layer} parentB 
function NeuralGeneticLayerCrossover(_child, _parentA, _parentB) {
	with (_child) {
		switch (type) {
			case NNLayerType.DENSE: {
				for (var i = 0; i < size; i++) {
					bias[@i] = choose(_parentA,_parentB).bias[i];
					for (var j = 0; j < input.size; j++) {
					weights[@i][@j] = choose(_parentA,_parentB).weights[i][j];
					}
				}
			} break;
			
			default: break;
		}
	}
}

/// @func NeuralGeneticCrossover(population, elitism);
/// @desc Makes offsprings from chosen elite.  Portion is given as relative value.
/// @param {array} population Array of structs/instances.
/// @param {real} elitism [0-1] What portion are considered as elites
function NeuralGeneticCrossover(_population, _elitism) {
	var count = array_length(_population);
	var eliteCount = max(1, ceil(count * _elitism));
	
	for (var c = eliteCount; c < count; c++) {
		var parentA = _population[irandom(eliteCount-1)].neuralNetwork.layers;
		var parentB = _population[irandom(eliteCount-1)].neuralNetwork.layers;
		var child = _population[c].neuralNetwork.layers;
		
		var size = _population[c].neuralNetwork.size;
		for (var i = 1; i < size; i++) {
			NeuralGeneticLayerCrossover(child[i],parentA[i],parentB[i]);
		}
	}
}

///	@func NeuralGeneticLayerMutation(target, amount, rate);
/// @desc Modifies target layer by randomly modifying parameters.
/// @param {layer} target Target layer where modifications are done
/// @param {real} amount	
/// @param {real} rate	
function NeuralGeneticLayerMutation(_target, _amount, _rate) {
	with (_target) {
		switch (type) {
			case NNLayerType.DENSE: {
				repeat (max(1, _amount*size)) {
					var i = irandom(size-1);
					bias[@i] += random_range(-_rate,_rate);
				}
				repeat (max(1, _amount*size*input.size)) {
					var i = irandom(size-1);
					var j = irandom(input.size-1);
					weights[@i][@j] += random_range(-_rate,_rate);
				}
			} break;
			default: break;
		}
	}
}

/// @func NeuralGeneticMutation(population, start, stop, amount, rate);
/// @desc Mutates given portion of population. Portion is given as relative values.
/// @param {array} population Array of structs/instances. 
/// @param {real} start [0-1] Start position of portion
/// @param {real} stop [0-1] End position of portion
/// @param {real} amount [0-1] Amount of mutations layer will have
/// @param {real} rate How large the mutations can be
function NeuralGeneticMutation(_population, _start, _stop, _amount, _rate) {
	var count = array_length(_population);
	_start = floor(_start*count);
	_stop = ceil(_stop*count);
	
	for (var c = _start; c < _stop; c++) {
		var target = _population[c].neuralNetwork.layers;
		var size = _population[c].neuralNetwork.size;
		
		for (var i = 1; i < size; i++) {
			NeuralGeneticLayerMutation(target[i], _amount, _rate);
		}
	}
}