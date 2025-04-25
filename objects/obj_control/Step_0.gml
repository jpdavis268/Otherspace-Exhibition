/// @description Process Management
// Adjust game to window
camera_set_view_size(view_camera[0], window_get_width(), window_get_height());
display_set_gui_size(window_get_width(), window_get_height());

// Toggle fullscreen
if (keyboard_check_pressed(global.settings.fullscreen_keybind)) {
	window_set_fullscreen(!window_get_fullscreen());
	global.settings.fullscreen = window_get_fullscreen();
}

// Game control
switch (room) {
	// If we are in the menu, set initialized to false.
	case rm_menu: {
		if (initialized) {
			audio_stop_all();
		}
		initialized = false;
		show_debug_log(false);
	} break;
	// If we are in the game and have not initialized, initialize.
	case rm_game: {
		if (!initialized) {
			game_init();
			initialized = true;
		}
	} break;
}
