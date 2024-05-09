if shouldHideScreen {
	coverAlpha += 0.04;
	draw_set_alpha(coverAlpha); draw_set_color(c_black);
	draw_rectangle(0,0,DISPLAY_WIDTH,DISPLAY_HEIGHT,false);
	draw_set_color(c_white); draw_set_font(fntViking);
	draw_text(DISPLAY_WIDTH/2,DISPLAY_HEIGHT/2,"Generating level...");
	
	if coverAlpha > 1 { // Go to rmGame
		coverAlpha = 0;
		room_goto(rmGame);
	}
}