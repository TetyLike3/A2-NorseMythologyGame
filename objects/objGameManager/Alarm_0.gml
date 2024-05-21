/// @description Round end
if (global.roundCounter == global.roundCount) {
	if playerWon room_goto(rmGameEnd) else room_goto(rmMainMenu);
} else {
	objPlayer.inputEnabled = false;
	focusedCharacters = [objEnemy];
}