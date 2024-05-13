/*
// Health bars
if room == rmGame {
	with (objPlayer) { other.DrawHealthBar(64,128,(charHealth/charHealthMax),false); }
	with (objEnemy) { other.DrawHealthBar(SCREEN_WIDTH-64,128,(charHealth/charHealthMax),true); }
}

// Debug
draw_text(16,16,string_concat("cameraCurrentX: ",cameraCurrentX," cameraCurrentY: ",cameraCurrentY));
draw_text(16,48,string_concat("cameraTargetX: ",cameraTargetX," cameraTargetY: ",cameraTargetY));
draw_text(16,80,string_concat("cameraCurrentW: ",cameraCurrentW," cameraCurrentH: ",cameraCurrentH));
draw_text(16,112,string_concat("cameraTargetW: ",cameraTargetW," cameraTargetH: ",cameraTargetH));
*/
// Column 2 X: 1024
draw_text(16,16,string_concat("Avg FPS: ",averageFPS));
draw_text(16,48,string_concat("Avg dT: ",averageDT));
draw_text(16,80,string_concat("Seed: ",random_get_seed()));