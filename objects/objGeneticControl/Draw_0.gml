/// @description

with (objEnemy) {
	draw_text(x, (y-sprite_height)-16,string_concat("fitness: ",aiFitness));
	draw_text(x, (y-sprite_height)-32,string_concat("state: ",currentState));
	draw_text(x, (y-sprite_height)-48,string_concat("xSpeed: ",xSpeed));
}


if !instance_exists(bestSpecimen) return;
with (bestSpecimen) {
	if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
		shader_set(sdrTint);
		shader_set_uniform_f(uTint,.8,.4,.4,1);
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_lime,.8);
		shader_reset();
	} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_lime,.8);
}
with (bestSpecimen.aiLocalEnemy) {
	if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
		shader_set(sdrTint);
		shader_set_uniform_f(uTint,.8,.4,.4,1);
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_green,.8);
		shader_reset();
	} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_green,.8);
} 