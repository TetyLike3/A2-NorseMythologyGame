/// @desc health bar
draw_sprite(sprHealthBarBg,0,HealthBarX,HealthBarY);
draw_sprite_stretched(sprHealthBar,0,HealthBarX,HealthBarY,(charHealth/charHealthMax)*498,128);
draw_sprite(sprHealthBarOutline,0,HealthBarX,HealthBarY);