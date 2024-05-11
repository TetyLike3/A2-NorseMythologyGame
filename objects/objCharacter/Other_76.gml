if !(layer_instance_get_instance(event_data[?"element_id"]) == id) return;

switch (event_data[?"message"]) {
	case "StepLeft": {
		audio_play_sound(sndStepL, 0, false);
	} break;
	case "StepRight": {
		audio_play_sound(sndStepR, 0, false);
	} break;
	case "LightSide": {
		audio_play_sound(sndLightSide, 0, false);
	} break;
	
	default: {
		//print(string_concat("new message logged for: ",object_get_name(object_index)));
		//print(event_data[?"message"]);
		array_push(spriteEventLog,event_data[?"message"]);
	} break;
}
