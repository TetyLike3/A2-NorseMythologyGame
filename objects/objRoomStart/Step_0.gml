print("step :3");
//print(layer_sequence_exists("Assets", sqButtonFadeIn));
if(!is_undefined(buttonFadeInId) and layer_sequence_is_finished(buttonFadeInId)) {
	print("something");
	room_goto(rmMainMenu);
}