/*if isNight { // Switch to moon
	if image_angle != 180 {
		spinLerpTime = lerp(spinLerpTime,1,((image_angle+1)/180)*spinLerpSpeed);
		image_angle = ceil(lerp(0,180,spinLerpTime)*10)/10;
	} else if !showStars {
		showStars = true;
	}
} else { // Switch to sun
	showStars = false;
	if (image_angle != 360) and (image_angle != 0) {
		spinLerpTime = lerp(spinLerpTime,1,((image_angle-179)/180)*spinLerpSpeed);
		image_angle = ceil(lerp(180,360,spinLerpTime)*10)/10;
	}
	if image_angle >= 360 image_angle = 0;
}

if(showStars and !buttonFadedIn and is_undefined(buttonFadeInId)) {
	buttonFadeInId = layer_sequence_create("Assets",960,540,sqButtonFadeIn);
}

//print(layer_sequence_exists("Assets", sqButtonFadeIn));
if(!buttonFadedIn and !is_undefined(buttonFadeInId) and layer_sequence_is_finished(buttonFadeInId)) {
	layer_sequence_destroy(buttonFadeInId);
	buttonFadedIn = true;
	
	var startButton = instance_create_layer(960,540,"Instances",objStartButton, {depth : 400});
	var optionsButton = instance_create_layer(960,248.5,"Instances",objOptionsButton, {depth : 400});
}*/
