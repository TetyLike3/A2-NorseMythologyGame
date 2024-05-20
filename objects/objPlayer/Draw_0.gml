event_inherited();

draw_text(x, (y-sprite_height)+16,string_concat("xSpeed: ",xSpeed));
draw_text(x, (y-sprite_height)+32,string_concat("INPUT_LEFT: ",INPUT_LEFT," INPUT_RIGHT: ",INPUT_RIGHT));
draw_text(x, (y-sprite_height)+48,string_concat("INPUT_UP: ",INPUT_LEFT," INPUT_DOWN: ",INPUT_RIGHT));
draw_text(x, (y-sprite_height)+64,string_concat("inputVectorX: ",inputVector[0]," inputVectorX: ",inputVector[1]));