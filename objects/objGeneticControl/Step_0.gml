remainingCounter = 0;
bestFitness = 0;

// Check population A
for (var i = 0; i < (count/2); i++) {
	var specimen = populationA[i];
	if !instance_exists(specimen) {
		array_delete(populationA, array_get_index(populationA,specimen), 1);
		continue;
	}
	if (specimen.aiLocalEnemy.currentState != CharacterStates.DEAD) remainingCounter++;
	if (i == 0) or (specimen.aiFitness > bestFitness) {
		bestFitness = specimen.aiFitness;
		bestSpecimen = specimen;
	}
}

// Check population B
for (var i = 0; i < (count/2); i++) {
	var specimen = populationB[i];
	if !instance_exists(specimen) {
		array_delete(populationB, array_get_index(populationB,specimen), 1);
		continue;
	}
	if (specimen.aiLocalEnemy.currentState != CharacterStates.DEAD) remainingCounter++;
	if (i == 0) or (specimen.aiFitness > bestFitness) {
		bestFitness = specimen.aiFitness;
		bestSpecimen = specimen;
	}
}

if (remainingCounter < lastRemainingCounter) {
	var diff = lastRemainingCounter - remainingCounter;
	
	timeLeft = ceil(timeLeft/(diff+.2)); // Decrease time left for others to finish
	
	//fitnessLowerLimit -= (diff*200); // Increase fitness lower limit to help remove others from softlock
}

// End this generation's simulation
if (remainingCounter == 0) or (timeLeft <= 0) or (keyboard_check_pressed(ord("P"))) or (bestFitness == fitnessLowerLimit) {
	if instance_exists(bestSpecimen) {
		if bestSpecimen.aiFitness > globalBestFitness {
			global.BestNetwork = bestSpecimen.neuralNetwork;
		}
	}
	var mergedPopulation = array_concat(populationA,populationB);
	
	NeuralGeneticSelection(mergedPopulation);
	NeuralGeneticCrossover(mergedPopulation, .1);
	NeuralGeneticMutation(mergedPopulation, .7, 1, .4*(remainingCounter/count), .2*(remainingCounter/count));
	generation++;
	timeLeft = timeLeftMax;
	globalBestFitness = max(bestFitness, globalBestFitness);
	fitnessLowerLimit = -500;
	
	instance_activate_object(specimenObj);
	with (specimenObj) {
		Restart();
	}
}

lastRemainingCounter = remainingCounter;
timeLeft--;

if (keyboard_check_pressed(vk_home)) and instance_exists(bestSpecimen) {
	var stringified = NeuralModelStringify(bestSpecimen.neuralNetwork);
	NeuralSaveModel(stringified);
}

if (keyboard_check_pressed(vk_insert)) {
	var newNetwork = NeuralLoadModel();
	if !is_undefined(newNetwork) {
		for (var i = 0; i < (count/2); i++) {
			NeuralModelCopy(populationA[i].neuralNetwork,newNetwork);
			NeuralModelCopy(populationB[i].neuralNetwork,newNetwork);
		}
	}
}