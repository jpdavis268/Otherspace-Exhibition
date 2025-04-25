/// @description Move Camera to Track Player Character
// Get window dimensions.
var _w = window_get_width();
var _h = window_get_height();

// Follow Player
if (instance_exists(obj_playerchar)) {
	camera_set_view_pos(view_camera[0], obj_playerchar.x - (_w * obj_inputhandler.camera_zoom / 2), obj_playerchar.y - (_h * obj_inputhandler.camera_zoom / 2));
}

// Set camera to window size.
camera_set_view_size(view_camera[0], _w * obj_inputhandler.camera_zoom, _h * obj_inputhandler.camera_zoom);