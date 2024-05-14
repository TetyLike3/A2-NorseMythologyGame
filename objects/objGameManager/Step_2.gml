// Camera movement
var _camX1 = infinity;
var _camY1 = infinity;
var _camX2 = -infinity;
var _camY2 = -infinity;

var _charsPosX = [];

for (var _charI = 0; _charI < array_length(focusedCharacters); ++_charI) {
	var _char = focusedCharacters[_charI];
	if (_char.x < _camX1) _camX1 = _char.x;
	if (_char.y < _camY1) _camY1 = _char.y;
	if (_char.x > _camX2) _camX2 = _char.x;
	if (_char.y > _camY2) _camY2 = _char.y;
	
	array_push(_charsPosX,_char.x);
}
_camY2 += floorPadding;

var _avgCharPosX = 0;
for (var _i = 0; _i < array_length(_charsPosX); ++_i) {
	_avgCharPosX += _charsPosX[_i];
}
_avgCharPosX /= array_length(_charsPosX);
_avgCharPosX += focusPadding;

cameraTargetW = max((_camX2 - _camX1) + (focusPadding*4),cameraMinW);
cameraTargetH = max(cameraTargetW*cameraAspRatio,cameraMinH);
cameraTargetX = (_avgCharPosX - (cameraTargetW/2))-focusPadding;
cameraTargetY = _camY2-(cameraTargetH);


// Exit game
if (gamepad_button_check_pressed(0,gp_start) or keyboard_check_pressed(vk_escape)) game_end();

timerRemaining--;

// Average FPS calculation
var DTLogSize = array_length(averageDTLog);
array_push(averageDTLog,delta_time);
if (DTLogSize > averageDTLogSize) array_delete(averageDTLog,0,1);
averageDT = 0;
for (var i = 0; i < DTLogSize; i++) {
	averageDT += averageDTLog[i];
}
averageDT /= DTLogSize;
averageFPS = 1000/(averageDT/1000);


// Switch between training mode and fighting mode
if keyboard_check_pressed(vk_pause) {
	if (room == rmTraining) room_goto(rmGame);
	if (room == rmGame) room_goto(rmTraining);
}