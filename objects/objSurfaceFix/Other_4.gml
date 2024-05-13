///@description Resize to fit display
var origW = 1920;
var origH = 1080;
var aspRatio = origW / origH;
var ww = origW;
var hh = origH;
if (SCREEN_WIDTH < SCREEN_HEIGHT) {
	ww = SCREEN_WIDTH;
	hh = ww / aspRatio;
} else {
	hh = SCREEN_HEIGHT;
	ww = hh * aspRatio;
}
surface_resize(application_surface, ww, hh);