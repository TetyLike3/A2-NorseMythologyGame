if shouldHideScreen {
	coverAlpha += 0.04;
	draw_set_alpha(coverAlpha); draw_set_color(c_black);
	draw_rectangle(0,0,SCREEN_WIDTH,SCREEN_HEIGHT,false);
	draw_set_color(c_white); draw_set_font(fntViking);
	
	if coverAlpha > 1 { 
		coverAlpha = 0;
		room_goto(rmMainMenu);
	}
}