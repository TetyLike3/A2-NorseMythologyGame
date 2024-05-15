//random_set_seed(940061644);

generation = 0;
time = 0;
timeLeftMax = (60*60);
timeLeft = timeLeftMax;

specimenObj = objEnemyTraining;
bestFitness = 0;
bestSpecimen = undefined;
globalBestFitness = 0;

countPerPop = 20;
count = countPerPop*2;
populationA = array_create(countPerPop);
populationB = array_create(countPerPop);
for (var i = 0; i < countPerPop; i++) {
	var charA = instance_create_layer((room_width/2)-2048,1056,"Instances",specimenObj);
	var charB = instance_create_layer((room_width/2)+2048,1056,"Instances",specimenObj);
	charA.targetChar = charB;
	charB.targetChar = charA;
	
	/*
	if !is_undefined(global.BestNetwork) {
		charA.neuralNetwork = global.BestNetwork;
		charB.neuralNetwork = global.BestNetwork;
	}
	*/
	
	charA.Restart();
	charB.Restart();
	populationA[@i] = charA;
	populationB[@i] = charB;
}

fitnessLowerLimit = -10000;
remainingCounter = count;
lastRemainingCounter = count;

function MutatePopulation() {
	var mergedPopulation = array_concat(populationA,populationB);
	NeuralGeneticSelection(mergedPopulation);
	NeuralGeneticCrossover(mergedPopulation, .1);
	NeuralGeneticMutation(mergedPopulation, .7, 1, .4*(remainingCounter/count), .2*(remainingCounter/count));
}