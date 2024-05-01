if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
	shader_set(sdrTint);
	shader_set_uniform_f(uTint,.8,.4,.4,1);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,1);
	shader_reset();
} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,1);

draw_text(x, (y-sprite_height)-64,string_concat("Health: ",charHealth));
draw_text(x, (y-sprite_height)-48,string_concat("Damage Timer: ",damageTimer));