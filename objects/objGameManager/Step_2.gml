cameraTargetX = objPlayer.x - (cameraWidth/2);
cameraTargetY = (objPlayer.y + 64) - (cameraHeight);

if (gamepad_button_check_pressed(0,gp_start) or keyboard_check_pressed(vk_escape)) game_end();