/// @description Prepare Lighting
// Get camera information.
var _cw = camera_get_view_width(view_camera[0]);
var _ch = camera_get_view_height(view_camera[0]);
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);

// Create the lighting surface.
// If the camera has a size (window is open), set surface size to it multiplied by 1.1 (to cover zooming out).
if (_cw > 0 && _ch > 0) {
	light_surface = surface_create(_cw * 1.1, _ch * 1.1);
}
// If the window is minimized, just create a 1 pixel surface.
else {
	light_surface = surface_create(1, 1);
}
// Darken the screen based on the current light level. then wait for other instances to process their lighting effects.
surface_set_target(light_surface);
draw_set_color(c_black);
draw_set_alpha(1 - light_level);
draw_rectangle(0, 0, _cw, _ch, false);
draw_reset();
surface_reset_target();



