/// @description Variable declarations
global.paused = false; // Whether game is paused.
pause_state = PAUSE_SUBMENU.MAIN; // Current pause submenu.
depth = -10000; // Ensure pause elements are above the rest of the GUI.

// Pause submenus
enum PAUSE_SUBMENU {
	MAIN,
	SETTINGS,
}
	
// Determine what text to show on the exit button based on whether or not we are in multiplayer.
var _exittext;
switch (obj_control.game_type) {
	case 0: {
		_exittext = "pause_sp_exit";
	} break;
	case 1: {
		_exittext = "pause_host_exit";
	} break;
	case 3: {
		_exittext = "pause_mp_exit";
	}
}

// Main Pause Menu
// Resume Game Button
resume_button = new Button(256, 64, "pause_resume", function() {
	// Reactivate all instances and enable player input.
	instance_activate_all();
	global.player_control = true;
	global.paused = false;
	keyboard_clear(vk_escape);
});
// Settings Button
settings_button = new Button(256, 64, "menu_settings", function() {
	pause_state = PAUSE_SUBMENU.SETTINGS;
});
// Exit Game Button
exit_button = new Button(256, 64, _exittext, function() {
	// Reactivate all instances for a single frame so we can save the game.
	instance_activate_all();
	alarm[0] = 1;
});