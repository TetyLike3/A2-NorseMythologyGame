if(room = rmSplashScreen){
	var randomIndex = irandom(array_length(loadingSequences));
	buttonFadeInId = instance_create_layer(0,0,"Assets",loadingSequences[randomIndex]);
}