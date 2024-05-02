if (spriteDir == 0) {
	image_xscale = 1;
} else {
	image_xscale = -1;
}

event_inherited();

draw_text(x, (y-sprite_height)-32,string_concat("xSpeed: ",xSpeed));
draw_text(x, (y-sprite_height)-16,string_concat("ySpeed: ",ySpeed));