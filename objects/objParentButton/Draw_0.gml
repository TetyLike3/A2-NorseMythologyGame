sprdraw_set_font(fntViking);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_dkgray);
draw_set_alpha(0)
var _x1 = x-(sprite_width/2);
var _y1 = y-(sprite_height/2);
var _x2 = x+(sprite_width/2);
var _y2 = y+(sprite_height/2);
draw_rectangle(_x1,_y1,_x2,_y2,false);
draw_set_color(c_white);
draw_set_alpha(1)
draw_text(x,y,buttonText);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fntSmallViking);