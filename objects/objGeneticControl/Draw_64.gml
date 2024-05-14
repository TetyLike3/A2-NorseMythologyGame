draw_text(192,16,string_concat("Remaining: ",remainingCounter));
draw_text(192,48,string_concat("Time Left: ",timeLeft));
draw_text(192,80,string_concat("Best Fitness: ",bestFitness));
draw_text(192,102,string_concat("Global Best Fitness: ",globalBestFitness));
draw_text(192,134,string_concat("Generation: ",generation));

if instance_exists(bestSpecimen) {
	draw_text(512,16,string_concat("X Input: ",bestSpecimen.aiXInput));
	draw_text(512,48,string_concat("Light Attack: ",bestSpecimen.aiLightAttackInput));
	draw_text(512,80,string_concat("Heavy Attack: ",bestSpecimen.aiHeavyAttackInput));
	draw_text(512,102,string_concat("Jump: ",bestSpecimen.aiJumpInput));
	draw_text(512,134,string_concat("Block: ",bestSpecimen.aiBlockInput));
	draw_text(512,166,string_concat("Grab: ",bestSpecimen.aiGrabInput));
	if instance_exists(bestSpecimen.targetChar) {
		draw_text(512,198,string_concat("Target Health: ",bestSpecimen.targetChar.charHealth));
	}

	bestSpecimen.neuralNetwork.Draw(384, 768, 1.8, 42, 42);
}