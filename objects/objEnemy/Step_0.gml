event_inherited();
HandleAIState();

if keyboard_check_pressed(ord("T")) {
	aiShouldTrain = true;
}

aiFitnessUpdateTimer--;