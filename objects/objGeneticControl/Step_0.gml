remainingCounter = 0;
bestFitness = 0;

for (var i = 0; i < count; i++) {
	var specimen = population[i];
	if !instance_exists(specimen) {
		count--;
		array_delete(population, array_get_index(population,specimen), 1);
		continue;
	}
	//if (specimen.aiFitness < -100) instance_deactivate_object(specimen);
	if instance_exists(specimen.aiLocalEnemy) remainingCounter++;
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
	/*
	if instance_exists(bestSpecimen) {
		if bestSpecimen.aiFitness > globalBestFitness {
			globalBestNetwork = bestSpecimen.neuralNetwork;
		} else {
			bestSpecimen.neuralNetwork = globalBestNetwork;
		};
	}
	*/
	
	NeuralGeneticSelection(population);
	NeuralGeneticCrossover(population, .1);
	NeuralGeneticMutation(population, .7, 1, .4*(remainingCounter/count), .2*(remainingCounter/count));
	generation++;
	timeLeft = timeLeftMax;
	globalBestFitness = max(bestFitness, globalBestFitness);
	fitnessLowerLimit = -500;
	
	instance_activate_object(objEnemy);
	with (objEnemy) {
		Restart();
	}
}

lastRemainingCounter = remainingCounter;
timeLeft--;

if (keyboard_check_pressed(vk_home)) and instance_exists(bestSpecimen) {
	var stringified = NeuralModelStringify(bestSpecimen.neuralNetwork);
	clipboard_set_text(stringified);
	show_message("clipped fr");
}

if (keyboard_check_pressed(vk_insert)) {
	var stringified = clipboard_get_text();
	var network = NeuralModelParse(stringified, true);
	
	if (is_undefined(network)) {
		show_message("Failed to parse model from clipboard.");
	} else {
		for (var i = 0; i < count; i++) {
			NeuralModelCopy(population[i].neuralNetwork,network);
		}
		show_message("Successfully parsed model :3");
	}
}