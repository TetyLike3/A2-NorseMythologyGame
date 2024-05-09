//randomise();
random_set_seed(940061644);

generation = 0;
time = 0;
timeLeftMax = (60*120);
timeLeft = timeLeftMax;
bestFitness = 0;
bestSpecimen = undefined;
globalBestFitness = 0;
globalBestNetwork = undefined;

count = 30;
population = array_create(count);
for (var i = 0; i < count; i++) {
	population[@i] = instance_create_layer(1856,1056,"Instances",objEnemy);
}
fitnessLowerLimit = -500;
remainingCounter = 0;
lastRemainingCounter = 0;