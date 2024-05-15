draw_text(x, (y-sprite_height)-96,string_concat("State: ",string(currentState)));

if (spriteDir == 1) {
	image_xscale = 1;
} else {
	image_xscale = -1;
}