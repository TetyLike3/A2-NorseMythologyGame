draw_text(16,144,string_concat("Remaining: ",remainingCounter));
draw_text(16,176,string_concat("Time Left: ",timeLeft));
draw_text(16,208,string_concat("Best Fitness: ",bestFitness));
draw_text(16,240,string_concat("Global Best Fitness: ",globalBestFitness));
draw_text(16,272,string_concat("Generation: ",generation));

if instance_exists(bestSpecimen) {
	draw_text(16,304,string_concat("Attack Input: ",bestSpecimen.aiLightAttackInput));
	draw_text(16,336,string_concat("Jump Input: ",bestSpecimen.aiJumpInput));
	if instance_exists(bestSpecimen.aiLocalEnemy) {
		draw_text(16,368,string_concat("Target Health: ",bestSpecimen.aiLocalEnemy.charHealth));
	}

	bestSpecimen.neuralNetwork.Draw(384, 768, 1.8, 42, 42);
}