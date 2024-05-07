remainingCounter = 0;
bestFitness = 0;

for (var i = 0; i < count; i++) {
	var specimen = population[i];
	if instance_exists(specimen.aiLocalEnemy) remainingCounter++;
	bestFitness = max(specimen.aiFitness, bestFitness);
	bestSpecimen = specimen;
}

if (remainingCounter == 0) or (timeLeft <= 0) {
	NeuralGeneticSelection(population);
	NeuralGeneticCrossover(population, .1);
	NeuralGeneticMutation(population, .3, 1, .2, .05);
	generation++;
	timeLeft = timeLeftMax;
	globalBestFitness = max(bestFitness, globalBestFitness);
	
	instance_activate_object(objEnemy);
	with (objEnemy) {
		Restart();
	}
}

timeLeft--;