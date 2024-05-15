if(room = rmSplashScreen){
	var randomIndex = irandom(array_length(loadingSequences)-1);
	buttonFadeInId = layer_sequence_create("Assets",room_width/2,room_height/2,loadingSequences[randomIndex]);
}