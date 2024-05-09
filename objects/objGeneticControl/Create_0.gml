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
population = array_create(count);
for (var i = 0; i < count; i++) {
	population[@i] = instance_create_layer(1856,1056,"Instances",specimenObj);
}
fitnessLowerLimit = -500;
remainingCounter = 0;
lastRemainingCounter = 0;