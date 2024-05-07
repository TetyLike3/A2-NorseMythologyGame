if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
	shader_set(sdrTint);
	shader_set_uniform_f(uTint,.8,.4,.4,1);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,.1);
	shader_reset();
} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,.1);

if (spriteDir == 0) {
	image_xscale = 1;
} else {
	image_xscale = -1;
}

/*
draw_text(x, (y-sprite_height)-96,string_concat("State: ",string(currentState)));
draw_text(x, (y-sprite_height)-80,string_concat("Health: ",charHealth));
draw_text(x, (y-sprite_height)-64,string_concat("Stun Timer: ",stunTimer));
draw_text(x, (y-sprite_height)-48,string_concat("Damage Timer: ",damageTimer));
draw_text(x, (y-sprite_height)-32,string_concat("xSpeed: ",xSpeed));
draw_text(x, (y-sprite_height)-16,string_concat("ySpeed: ",ySpeed));
*/