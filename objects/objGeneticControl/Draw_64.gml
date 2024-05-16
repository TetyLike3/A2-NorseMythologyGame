draw_text(192,16,string_concat("Remaining: ",remainingCounter));
draw_text(192,48,string_concat("Time Left: ",timeLeft));
draw_text(192,80,string_concat("Best Fitness: ",bestFitness));
draw_text(192,102,string_concat("Global Best Fitness: ",globalBestFitness));
draw_text(192,134,string_concat("Generation: ",generation));

if instance_exists(bestSpecimen) {
	with (bestSpecimen) {
		draw_text(512,16,string_concat("X Input: ",aiInputLeft + aiInputRight));
		draw_text(512,48,string_concat("Y Input: ",aiInputDown + aiInputUp));
		draw_text(512,80,string_concat("Light Attack: ",aiLightAttackInput));
		draw_text(512,102,string_concat("Heavy Attack: ",aiHeavyAttackInput));
		draw_text(512,134,string_concat("Block: ",aiBlockInput));
		draw_text(512,166,string_concat("Grab: ",aiGrabInput));
		if instance_exists(targetChar) {
			draw_text(512,198,string_concat("Target Health: ",targetChar.charHealth));
		}
		neuralNetwork.Draw(384, 768, 1.8, 42, 42);
	}

}