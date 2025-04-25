/// @description Draw hover text box, if needed.
if (global.hover_text != "") {
	draw_text_box(window_mouse_get_x(), window_mouse_get_y() + 12, global.hover_text, global.hover_center);
	global.hover_text = "";
	global.hover_center = false;
}