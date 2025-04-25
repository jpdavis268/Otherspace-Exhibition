// Load settings
// Will need some way of handling differences in settings files eventually!
global.settings = load_json("settings.json");

// Settings submenu.
enum SETTINGS {
	MAIN,
	GENERAL,
	GRAPHICAL,
	AUDIO,
	CONTROLS,
	LANGUAGE
}

// Define buttons
global.settings_buttons = {
	// Global
	general_button : new Button(256, 64, "menu_settings_general", function() {
		draw_settings_menu.submenu = SETTINGS.GENERAL;
	}),
	graphics_button : new Button(256, 64, "menu_settings_graphics", function() {
		draw_settings_menu.submenu = SETTINGS.GRAPHICAL;
	}), 
	audio_button : new Button(256, 64, "menu_settings_audio", function() {
		draw_settings_menu.submenu = SETTINGS.AUDIO;
	}), 
	controls_button : new Button(256, 64, "menu_settings_controls", function() {
		draw_settings_menu.submenu = SETTINGS.CONTROLS;
	}), 
	lang_button : new Button(256, 64, "menu_settings_lang", function() {
		draw_settings_menu.submenu = SETTINGS.LANGUAGE;	
	}), 
	exit_button : new Button(256, 64, "menu_settings_exit", function() {
		save_json(global.settings, "settings.json");
		if (room == rm_menu) {
			obj_menu.menu_state = MM_SUBMENU.MAIN;
		}
		else {
			obj_pausehandler.pause_state = PAUSE_SUBMENU.MAIN;
		}
	}),
	cancel_button : new Button(256, 64, "menu_settings_back", function() {
		if (draw_settings_menu.submenu = SETTINGS.GRAPHICAL) {
			// Reload setttings from file.
			global.settings = load_json("settings.json");
		}
		draw_settings_menu.submenu = SETTINGS.MAIN;
	}),
	// General
	general_options : [
		new Button(256, 64, "menu_settings_gen_timeformat", function() {
			global.settings.time_format = !global.settings.time_format;
		}),
		new Button(256, 64, "menu_settings_gen_dateformat", function() {
			global.settings.date_format = !global.settings.date_format;
		}),
		new Slider(256, "menu_settings_gen_autosave_interval", function() {
			global.settings.autosave_interval = round(global.settings_buttons.general_options[2].position * 5);
		}),
	],
	// Graphics
	graphics_options : [
		new Button(256, 64, "menu_settings_g_fullscreen", function() {
			global.settings.fullscreen = !global.settings.fullscreen;
		}),
	],
	// Audio
	audio_options : [
		new Slider(256, "menu_settings_a_master", function() {
			global.settings.master_volume = global.settings_buttons.audio_options[0].position;
		}, global.settings.master_volume),
		new Slider(256, "menu_settings_a_ambience", function() {
			global.settings.ambience_volume = global.settings_buttons.audio_options[1].position;
		}, global.settings.ambience_volume),
		new Slider(256, "menu_settings_a_entities", function() {
			global.settings.entity_volume = global.settings_buttons.audio_options[2].position;
		}, global.settings.entity_volume),
		new Slider(256, "menu_settings_a_tile", function() {
			global.settings.tile_volume = global.settings_buttons.audio_options[3].position;
		}, global.settings.tile_volume),
		new Slider(256, "menu_settings_a_ui", function() {
			global.settings.ui_volume = global.settings_buttons.audio_options[4].position;
		}, global.settings.ui_volume),
	],
	apply_button : new Button(256, 64, "menu_settings_g_apply", function() {
		// Reload settings
		// Not terribly efficient, but this is executed so rarely it doesn't really matter.
		save_json(global.settings, "settings.json");
	}),
	// Controls
	bind_buttons : [
		new BindButton(256, 64, "menu_settings_c_chat", "chat_bind", ord("C")),
		new BindButton(256, 64, "menu_settings_c_fullscreen", "fullscreen_bind", vk_f12),
		new BindButton(256, 64, "menu_settings_c_zoomout", "camera_zoom_out_bind", ord("X")),
		new BindButton(256, 64, "menu_settings_c_zoomin", "camera_zoom_in_bind", ord("Z")),
		new BindButton(256, 64, "menu_settings_c_zoomreset", "camera_zoom_reset_bind", ord("R")),
		new BindButton(256, 64, "menu_settings_c_moveup", "move_up_bind", ord("W")),
		new BindButton(256, 64, "menu_settings_c_moveleft", "move_left_bind", ord("A")),
		new BindButton(256, 64, "menu_settings_c_movedown", "move_down_bind", ord("S")),
		new BindButton(256, 64, "menu_settings_c_moveright", "move_right_bind", ord("D")),
		new BindButton(256, 64, "menu_settings_c_buildmode", "build_mode_bind", ord("T")),
		new BindButton(256, 64, "menu_settings_c_inventory", "inventory_bind", ord("E")),
		new BindButton(256, 64, "menu_settings_c_drop", "drop_bind", ord("Q")),
		new BindButton(256, 64, "menu_settings_c_sweep", "sweep_bind", ord("F")),
	],
	bind_reset_button : new Button(256, 64, "menu_settings_c_resetall", function() {
		for (var _i = 0; _i < array_length(global.settings_buttons.bind_buttons); _i++) {
			variable_global_set(global.settings_buttons.bind_buttons[_i].bind, global.settings_buttons.bind_buttons[_i].defaultbind);
			variable_struct_set(global.settings, global.settings_buttons.bind_buttons[_i].bind, global.settings_buttons.bind_buttons[_i].defaultbind)
			global.settings_buttons.bind_buttons[_i].bind_text = vk_tostring(variable_global_get(global.settings_buttons.bind_buttons[_i].bind));
		}
	}),
	// Language
	lang_buttons : [
		new Button(256, 64, "English (US)", function() {
			global.settings.language = "en_us";
			global.text_map = load_json("lang\\en_us.json");
		}),
	],
}

/**
 * Draw the settings submenu, which is itself a submenu of both the main menu and pause menu.
 */
function draw_settings_menu() {
	// Store current submenu and gui parameters.
	static submenu = SETTINGS.MAIN;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	
	switch (submenu) {
		case SETTINGS.MAIN: 
			// ESC
			if (keyboard_check_pressed(vk_escape)) {
				if (room == rm_menu) {
					obj_menu.menu_state = MM_SUBMENU.MAIN;
				}
				else {
					obj_pausehandler.pause_state = PAUSE_SUBMENU.MAIN;
				}
			}
			
			// Draw Header
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _i = (_gh / 2) - 144
			draw_text(_gw / 2, _i - 72, get_text("menu_settings"));
			
			// Draw Buttons
			global.settings_buttons.general_button.draw(_gw / 2, _i); _i += 72;
			global.settings_buttons.graphics_button.draw(_gw / 2, _i); _i += 72;
			global.settings_buttons.audio_button.draw(_gw / 2, _i); _i += 72;
			global.settings_buttons.controls_button.draw(_gw / 2, _i); _i += 72;
			global.settings_buttons.lang_button.draw(_gw / 2, _i); _i += 72;
			global.settings_buttons.exit_button.draw(_gw / 2, _i);
			draw_reset();
		break;
		case SETTINGS.GENERAL: 
			// ESC
			if (keyboard_check_pressed(vk_escape)) {
				method_call(global.settings_buttons.cancel_button.action);
			}
			
			// Draw Header
			draw_rectangle_color(0, 0, _gw, 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_gw / 2, 25, get_text("menu_settings_general"));
			
			// Options
			// This will need to be reworked once more options are added.
			global.settings_buttons.general_options[0].draw(_gw / 2, 132);
			global.settings_buttons.general_options[1].draw(_gw / 2, 204);
			global.settings_buttons.general_options[2].draw(_gw / 2 - 128, 276);
			
			// Keep data up to date
			global.settings_buttons.general_options[0].text = get_text("menu_settings_gen_timeformat") + get_text(global.settings.time_format ? "menu_settings_gen_24hr" : "menu_settings_gen_ampm");
			global.settings_buttons.general_options[1].text = get_text("menu_settings_gen_dateformat") + string(global.settings.date_format ? "mm/dd/yyyy" : "dd/mm/yyyy");
			global.settings_buttons.general_options[2].position = global.settings.autosave_interval / 5;
			global.settings_buttons.general_options[2].label = get_text("menu_settings_gen_autosave_interval") + method_call(function() {
				switch (global.settings.autosave_interval) {
					case 0: return "5 minutes";
					case 1: return "10 minutes";
					case 2: return "15 minutes";
					case 3: return "20 minutes";
					case 4: return "30 minutes";
					case 5: return "1 hour";
					default: return "null";
				}
			});
			draw_reset();
			
			// Draw Footer
			draw_rectangle_color(0, _gh - 80, _gw, _gh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			global.settings_buttons.cancel_button.draw(_gw / 2, _gh - 40);
		break;
		case SETTINGS.GRAPHICAL:
			// ESC
			if (keyboard_check_pressed(vk_escape)) {
				method_call(global.settings_buttons.cancel_button.action);
			}
			
			// Draw Header
			draw_rectangle_color(0, 0, _gw, 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_gw / 2, 25, get_text("menu_settings_graphics"));
			
			// Options
			// This will need to be reworked once more options are added.
			global.settings_buttons.graphics_options[0].draw(_gw / 2, 132);
			
			// Keep text up to date
			global.settings_buttons.graphics_options[0].text = get_text("menu_settings_g_fullscreen") + get_text(global.settings.fullscreen ? "menu_settings_on" : "menu_settings_off");
			draw_reset();
			
			// Draw Footer
			draw_rectangle_color(0, _gh - 80, _gw, _gh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			global.settings_buttons.cancel_button.draw(_gw / 2 - 256, _gh - 40);
			global.settings_buttons.apply_button.draw(_gw / 2 + 256, _gh - 40);
		break;
		case SETTINGS.AUDIO: 
			// ESC
			if (keyboard_check_pressed(vk_escape)) {
				method_call(global.settings_buttons.cancel_button.action, []);
			}
			
			// Draw Header
			draw_rectangle_color(0, 0, _gw, 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_gw / 2, 25, get_text("menu_settings_audio"));
			
			// Draw volume sliders.
			var _i = 96;
			global.settings_buttons.audio_options[0].draw(_gw / 2 - 128, _i); _i += 72;
			global.settings_buttons.audio_options[1].draw(_gw / 2 - 128, _i); _i += 72;
			global.settings_buttons.audio_options[2].draw(_gw / 2 - 128, _i); _i += 72;
			global.settings_buttons.audio_options[3].draw(_gw / 2 - 128, _i); _i += 72;
			global.settings_buttons.audio_options[4].draw(_gw / 2 - 128, _i); _i += 72;
			
			// Update volume sliders.
			global.settings_buttons.audio_options[0].label = get_text("menu_settings_a_master") + string(round(global.settings.master_volume * 100));
			global.settings_buttons.audio_options[1].label = get_text("menu_settings_a_ambience") + string(round(global.settings.ambience_volume * 100));
			global.settings_buttons.audio_options[2].label = get_text("menu_settings_a_entities") + string(round(global.settings.entity_volume * 100));
			global.settings_buttons.audio_options[3].label = get_text("menu_settings_a_tile") + string(round(global.settings.tile_volume * 100));
			global.settings_buttons.audio_options[4].label = get_text("menu_settings_a_ui") + string(round(global.settings.ui_volume * 100));
			
			// Update volume
			audio_master_gain(global.settings.master_volume);
			audio_group_set_gain(audiogroup_ambience, global.settings.ambience_volume, 0);
			audio_group_set_gain(audiogroup_entities, global.settings.entity_volume, 0);
			audio_group_set_gain(audiogroup_ui, global.settings.ui_volume, 0);
			
			// Draw Footer
			draw_rectangle_color(0, _gh - 80, _gw, _gh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			global.settings_buttons.cancel_button.draw(_gw / 2, _gh - 40);
		break;
		case SETTINGS.CONTROLS:
			// ESC
			if (keyboard_check_pressed(vk_escape)) {
				method_call(global.settings_buttons.cancel_button.action, []);
			}
			
			// Draw Header
			draw_rectangle_color(0, 0, _gw, 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_gw / 2, 25, get_text("menu_settings_controls"));
			draw_reset();
			
			// Keybinds
			var _perrow = floor(_gw / 264);
			
			var _i = (_gw / 2) - ((_perrow / 2) * 264 - 132);
			var _j = 132;
			var _lbound = _i;
			var _rbound = (_gw / 2) + ((_perrow  / 2) * 264 - 132);
			
			// Draw bind buttons
			for (var _k = 0; _k < array_length(global.settings_buttons.bind_buttons); _k++) {
				global.settings_buttons.bind_buttons[_k].draw(_i, _j);
				if (_i < _rbound) {
					_i += 264;
				}
				else {
					_i = _lbound;
					_j += 72;
				}
			}
			
			// Draw Footer
			draw_rectangle_color(0, _gh - 80, _gw, _gh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			global.settings_buttons.cancel_button.draw(_gw / 2 - 256, _gh - 40);
			global.settings_buttons.bind_reset_button.draw(_gw / 2 + 256, _gh - 40);
		break;
		case SETTINGS.LANGUAGE:
			// ESC
			if (keyboard_check_pressed(vk_escape)) {
				method_call(global.settings_buttons.cancel_button.action, []);
			}
			
			// Draw Header
			draw_rectangle_color(0, 0, _gw, 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_gw / 2, 25, get_text("menu_settings_lang"));
			
			// Draw Buttons
			var _perrow = floor(_gw / 264);
			
			var _i = (_gw / 2) - ((_perrow / 2) * 264 - 132);
			var _j = 132;
			var _lbound = _i;
			var _rbound = (_gw / 2) + ((_perrow  / 2) * 264 - 132);
			
			// Draw  buttons
			for (var _k = 0; _k < array_length(global.settings_buttons.lang_buttons); _k++) {
				global.settings_buttons.lang_buttons[_k].draw(_i, _j);
				if (_i < _rbound) {
					_i += 264;
				}
				else {
					_i = _lbound;
					_j += 72;
				}
			}
			draw_reset();
			
			// Draw Footer
			draw_rectangle_color(0, _gh - 80, _gw, _gh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
			global.settings_buttons.cancel_button.draw(_gw / 2, _gh - 40);
		break;
	}
}