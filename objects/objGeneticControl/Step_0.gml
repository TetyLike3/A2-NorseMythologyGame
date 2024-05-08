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

// End this generation's simulation
if (remainingCounter == 0) or (timeLeft <= 0) {
	NeuralGeneticSelection(population);
	NeuralGeneticCrossover(population, .1);
	NeuralGeneticMutation(population, .2, 1, .4, .1);
	generation++;
	timeLeft = timeLeftMax;
	globalBestFitness = max(bestFitness, globalBestFitness);
	
	instance_activate_object(objEnemy);
	with (objEnemy) {
		Restart();
	}
}

timeLeft--;