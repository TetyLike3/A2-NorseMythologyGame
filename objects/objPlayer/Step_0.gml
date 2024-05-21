event_inherited();

if inputEnabled {
	inputVector[0] = getPlayerHorizontalInput();
	inputVector[1] = getPlayerVerticalInput();
} else {
	inputVector = [0,0];
}

HandlePlayerState();