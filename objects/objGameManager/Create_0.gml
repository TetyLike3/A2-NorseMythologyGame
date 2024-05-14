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
function SecToFrames(_seconds) {
	return _seconds*game_get_speed(gamespeed_fps);
}
timerMax = SecToFrames(60); // Time limit (in frames)
timerRemaining = timerMax;
gameGravity = 0.6;

averageDTLogSize = 240;
averageDTLog = [];
averageDT = 0;
averageFPS = 0;

charDrawAlpha = 1;

// Health Bar
healthBarWidth = sprite_get_width(sprHealthBar1Outline)*2;
healthBarHeight = sprite_get_height(sprHealthBar1Outline)*1.5;

function DrawHealthBar(_x,_y,_val,_flipped) {
    var _fillWidth = round(_val * healthBarWidth);
    if _flipped {
        _x -= healthBarWidth;
        draw_set_halign(fa_center);
        draw_sprite_stretched(sprHealthBar2Bg,0,_x,_y,healthBarWidth,healthBarHeight);
        draw_sprite_stretched(sprHealthBar2,0,_x,_y,_fillWidth,healthBarHeight);
        draw_sprite_stretched(sprHealthBar2Outline,0,_x,_y,healthBarWidth,healthBarHeight);
    } else {
        draw_sprite_stretched(sprHealthBar1Bg,0,_x,_y,healthBarWidth,healthBarHeight);
        draw_sprite_stretched(sprHealthBar1,0,_x + healthBarWidth - _fillWidth,_y,_fillWidth,healthBarHeight);
        draw_sprite_stretched(sprHealthBar1Outline,0,_x,_y,healthBarWidth,healthBarHeight);
    }
}