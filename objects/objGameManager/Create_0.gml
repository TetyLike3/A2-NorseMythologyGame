// Camera
cameraCurrentX = 0;
cameraCurrentY = 0;
cameraCurrentW = 1920;
cameraCurrentH = 1080;
cameraTargetX = cameraCurrentX;
cameraTargetY = cameraCurrentY;
cameraTargetW = cameraCurrentW;
cameraTargetH = cameraCurrentH;
cameraMinW = 1280;
cameraMinH = 720;

cameraAspRatio = cameraCurrentH/cameraCurrentW;

cameraLerpTime = 5;

focusedCharacters = [];
focusPadding = 256;
floorPadding = 64;


// Gameplay
gameGravity = 0.6;

averageDTLogSize = 240;
averageDTLog = [];
averageDT = 0;
averageFPS = 0;

charDrawAlpha = 1;

// Health Bar
healthBarWidth = sprite_get_width(sprHealthBar1Outline)*2;
healthBarHeight = sprite_get_height(sprHealthBar1Outline);

function DrawHealthBar(_x,_y,_val,_flipped) {
	if _flipped {
		_x -= healthBarWidth;
		draw_sprite_stretched(sprHealthBar2Bg,0,_x,_y,healthBarWidth,healthBarHeight);
		draw_sprite_stretched(sprHealthBar2,0,_x,_y,_val*healthBarWidth,healthBarHeight);
		draw_sprite_stretched(sprHealthBar2Outline,0,_x,_y,healthBarWidth,healthBarHeight);
	} else {
		draw_sprite_stretched(sprHealthBar1Bg,0,_x,_y,healthBarWidth,healthBarHeight);
		draw_sprite_stretched(sprHealthBar1,0,_x,_y,_val*healthBarWidth,healthBarHeight);
		draw_sprite_stretched(sprHealthBar1Outline,0,_x,_y,healthBarWidth,healthBarHeight);
	}
}