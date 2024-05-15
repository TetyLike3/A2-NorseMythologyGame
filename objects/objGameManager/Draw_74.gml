// Health bars
if room == rmGame {
	with (objPlayer) {
		other.DrawHealthBar(32,88,(charHealth/charHealthMax),false);
		other.DrawStaminaBar(32,256,(staminaLevel/100),false);
	}
	with (objEnemy) {
		other.DrawHealthBar(SCREEN_WIDTH-32,88,(charHealth/charHealthMax),true);
		other.DrawStaminaBar(SCREEN_WIDTH-32,256,(staminaLevel/100),true);
	}
	DRAW_CENTRE;
	draw_set_font(fntViking);
	draw_text_transformed((SCREEN_WIDTH/2),200,round(timerRemaining/100),1.5,1.5,0);
	DRAW_RESET;
}

/*
// Debug
draw_text(16,16,string_concat("cameraCurrentX: ",cameraCurrentX," cameraCurrentY: ",cameraCurrentY));
draw_text(16,48,string_concat("cameraTargetX: ",cameraTargetX," cameraTargetY: ",cameraTargetY));
draw_text(16,80,string_concat("cameraCurrentW: ",cameraCurrentW," cameraCurrentH: ",cameraCurrentH));
draw_text(16,112,string_concat("cameraTargetW: ",cameraTargetW," cameraTargetH: ",cameraTargetH));
*/

// Column 2 X: 1024
DRAW_RESET;
draw_set_font(fntSmallViking);
draw_text(16,16,string_concat("Avg FPS: ",averageFPS));
draw_text(16,48,string_concat("Avg dT: ",averageDT));
draw_text(16,80,string_concat("Seed: ",random_get_seed()));

DRAW_RESET;