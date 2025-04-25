/// @description Render Lighting
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);

// Draw the lighting surface once other instances have been able to add in their effects.
draw_surface(light_surface, _cx, _cy);
surface_free(light_surface);