/// @description Handle Pausing
if (keyboard_check_pressed(vk_escape) && global.player_control) {
	// Unpausing will be handled below.
	global.paused = true;
	keyboard_clear(vk_escape);
}

// The break statement is omitted after case 0, as the singleplayer pause will
// be an extension of the multiplayer pause and thus fallthrough behavior is ideal.
if (global.paused) {
	// Get GUI dimensions.
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	
	switch (obj_control.game_type) {
		case 0: { // Singleplayer (Full Pause);
			// Stop game from ticking.
			instance_deactivate_layer("Server");
			instance_deactivate_object(obj_client);
		}
		default: { // Multiplayer (Client Pause)
			// Disable player control
			global.player_control = false;
			
			// Darken screen
			draw_set_alpha(0.5);
			draw_rectangle_color(0, 0, window_get_width() * 1.2, window_get_height() * 1.2, c_black, c_black, c_black, c_black, false);
			draw_reset();
		
			switch (pause_state) {
				case (PAUSE_SUBMENU.MAIN): { // Main Pause Menu
					draw_set_halign(fa_center);
					draw_set_valign(fa_middle);
					var _i = (_gh / 2) - 72;
					draw_text(_gw / 2, _i - 72, get_text("pause_header"));
					
					// Draw buttons
					resume_button.draw(_gw / 2, _i); _i += 72;
					settings_button.draw(_gw / 2, _i); _i += 72;
					exit_button.draw(_gw / 2, _i);
					draw_reset();
					
					// Return to game if ESC pressed.
					if (keyboard_check_pressed(vk_escape)) {
						instance_activate_all();
						global.player_control = true;
						global.paused = false;
						keyboard_clear(vk_escape);
					}
				} break;
				case (PAUSE_SUBMENU.SETTINGS): {
					draw_settings_menu();
				} break;
			}
		}
	}
}