if (room == rmGame) {
	objPlayer.targetChar = objEnemy;
	objEnemy.targetChar = objPlayer;
	global.roundCounter++;
	if (audio_is_playing(sndMainMenuMusic)) audio_stop_sound(sndMainMenuMusic);
	audio_play_sound(sndRoundStart,100,false);
}