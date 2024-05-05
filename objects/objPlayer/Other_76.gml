// Footstep sounds
if (event_data[? "event_type"] == "sprite event") {
	switch (event_data[? "message"]) {
		case "StepLeft": {
			audio_play_sound(sndStepL, 0, false);
		} break;
		case "StepRight": {
			audio_play_sound(sndStepR, 0, false);
		} break;
	}
}