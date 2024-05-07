// Neural Network Genetics

function NeuralGeneticSelection(_population) {
	array_sort(_population, function(A, B) {
		return B.aiFitness - A.aiFitness;
	});
}

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