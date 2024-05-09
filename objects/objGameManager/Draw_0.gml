/// @description Draw Characters

if (room == rmTraining) {
	charDrawAlpha = .3;
	game_set_speed(240,gamespeed_fps);
}
if (room == rmGame) {
	charDrawAlpha = 1;
	game_set_speed(60,gamespeed_fps);
}

with (objCharacter) {
	if (spriteDir == 0) {
		image_xscale = 1;
	} else {
		image_xscale = -1;
	}
	
	if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
		shader_set(sdrTint);
		shader_set_uniform_f(uTint,.8,.4,.4,1);
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_grey,other.charDrawAlpha);
		shader_reset();
	} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_grey,other.charDrawAlpha);
}