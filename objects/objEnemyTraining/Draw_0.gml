event_inherited();

draw_text(x, (y-sprite_height)-128,string_concat("fromcentre reward: ",(.5-(point_distance(x,y,room_width/2,y)/(room_width/2)))*2.2));