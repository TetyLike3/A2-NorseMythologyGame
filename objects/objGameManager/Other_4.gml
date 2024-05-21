if (room == rmGame) {
	objPlayer.targetChar = objEnemy;
	objEnemy.targetChar = objPlayer;
	global.roundCounter++;
	audio_play_sound(sndRoundStart,100,false);
}