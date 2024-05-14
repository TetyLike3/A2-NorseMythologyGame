draw_set_font(fntViking);
draw_set_color(c_red);
draw_set_alpha(timeLeft/lifetime);
draw_text(x,y,valueShown);
DRAW_RESET;