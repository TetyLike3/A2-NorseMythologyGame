/// @description Draw best specimen with higher alpha
with (bestSpecimen) {
	if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
		shader_set(sdrTint);
		shader_set_uniform_f(uTint,.8,.4,.4,1);
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,.8);
		shader_reset();
	} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,.8);
}