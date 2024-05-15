/// @description Draw Characters

if (room == rmTraining) {
	charDrawAlpha = .3;
	game_set_speed(360,gamespeed_fps);
	audio_master_gain(0.2);
}
if (room == rmGame) {
	charDrawAlpha = 1;
	game_set_speed(60,gamespeed_fps);
	audio_master_gain(1);
}

with (objCharacter) {	
	var drawCol = c_grey;
	if (room == rmTraining) and (object_index == objEnemyTraining) {
		var fitnessScore = aiFitness/objGeneticControl.bestFitness;
		drawCol = make_color_rgb((fitnessScore-0.5)*255,(0.5-fitnessScore)*255,80);
	}
	if (damageTimer > 0) and ((damageTimer mod damageFlashInterval) > (damageFlashInterval/2)) {
		shader_set(sdrTint);
		shader_set_uniform_f(uTint,.8,.4,.4,1);
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,drawCol,other.charDrawAlpha);
		shader_reset();
	} else draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,drawCol,other.charDrawAlpha);
}