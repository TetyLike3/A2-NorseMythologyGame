//randomise();
random_set_seed(940061644);

generation = 0;
time = 0;
timeLeftMax = (60*120);
timeLeft = timeLeftMax;

specimenObj = objEnemyTraining;
bestFitness = 0;
bestSpecimen = undefined;
globalBestFitness = 0;
global.BestNetwork = undefined;

count = 30;
populationA = array_create(count/2);
populationB = array_create(count/2);
for (var i = 0; i < (count/2); i++) {
	var charA = instance_create_layer(-192,1056,"Instances",specimenObj);
	var charB = instance_create_layer(3904,1056,"Instances",specimenObj);
	charA.aiLocalEnemy = charB;
	charB.aiLocalEnemy = charA;
	charA.Restart();
	charB.Restart();
	populationA[@i] = charA;
	populationB[@i] = charB;
}
fitnessLowerLimit = -500;
remainingCounter = 0;
lastRemainingCounter = 0;