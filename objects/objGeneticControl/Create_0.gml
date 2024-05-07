generation = 0;
time = 0;
timeLeftMax = (60*10);
timeLeft = timeLeftMax;
bestFitness = 0;
bestSpecimen = undefined;
globalBestFitness = 0;

count = 10;
population = array_create(count);
for (var i = 0; i < count; i++) {
	population[@i] = instance_create_layer(1856,1056,"Instances",objEnemy);
}
remainingCounter = 0;