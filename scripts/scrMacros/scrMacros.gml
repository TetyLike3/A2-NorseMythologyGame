#macro INPUT_DEADZONE 0.2

#macro INPUT_LATTACK (inputEnabled and (gamepad_button_check_pressed(deviceIndex,gp_face4) or gamepad_button_check_pressed(deviceIndex,gp_face2) or mouse_check_button_pressed(mb_left)))
#macro INPUT_HATTACK (inputEnabled and (gamepad_button_check_pressed(deviceIndex,gp_face3) or mouse_check_button_pressed(mb_right)))
#macro INPUT_LEFT (inputEnabled and ((gamepad_axis_value(deviceIndex, gp_axislh) < -INPUT_DEADZONE) or keyboard_check(ord("A"))))
#macro INPUT_RIGHT (inputEnabled and ((gamepad_axis_value(deviceIndex, gp_axislh) > INPUT_DEADZONE) or keyboard_check(ord("D"))))
#macro INPUT_UP (inputEnabled and ((gamepad_axis_value(deviceIndex, gp_axislv) > INPUT_DEADZONE) or keyboard_check(ord("W"))))
#macro INPUT_DOWN (inputEnabled and ((gamepad_axis_value(deviceIndex, gp_axislv) < -INPUT_DEADZONE) or keyboard_check(ord("S"))))
#macro INPUT_JUMP (inputEnabled and (gamepad_button_check_pressed(deviceIndex,gp_face1) or keyboard_check_pressed(vk_space)))
#macro INPUT_BLOCK (inputEnabled and (gamepad_button_check(deviceIndex,gp_shoulderlb) or gamepad_button_check(deviceIndex,gp_shoulderrb) or keyboard_check(ord("Q"))))
#macro INPUT_GRAB (inputEnabled and (gamepad_button_check(deviceIndex,gp_shoulderl) or gamepad_button_check(deviceIndex,gp_shoulderr) or keyboard_check(ord("E"))))
#macro INPUT_TAUNT (inputEnabled and (keyboard_check_pressed(ord("T"))) or gamepad_button_check_pressed(deviceIndex,gp_padu))

#macro END_OF_SPRITE (ceil(image_index) == image_number)
#macro FACE_TARGET if instance_exists(targetChar) spriteDir = (x < targetChar.x)


// Set initial global values too
global.BestNetwork = undefined;
global.ActiveNetwork = undefined;
global.roundCounter = 0;
global.roundCount = 2;

#macro SCREEN_WIDTH surface_get_width(application_surface)
#macro SCREEN_HEIGHT surface_get_height(application_surface)

#macro DRAW_RESET draw_set_font(fntDefault); draw_set_color(c_white); draw_set_alpha(1)
#macro DRAW_CENTRE draw_set_halign(fa_center); draw_set_valign(fa_middle)