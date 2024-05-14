
if(roomStarted) {
	buttonFadeInId = layer_sequence_create("Assets",960,540,sqLoading);
	print("I GOT")
	roomStarted=false
}

//print(layer_sequence_exists("Assets", sqButtonFadeIn));
if(!is_undefined(buttonFadeInId) and layer_sequence_is_finished(buttonFadeInId)) {
	print("something")
	room_goto(rmMainMenu);
	
	
}