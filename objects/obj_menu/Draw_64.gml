/// @description Draw Menu
// Get GUI dimensions
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Draw a confirmation dialogue if it exists.
if (variable_global_exists("confirm_dialogue") && !is_undefined(global.confirm_dialogue)) {
	global.confirm_dialogue.draw(_gw / 2, _gh / 2);
	exit;
}

switch (menu_state) {
	// Title Menu
	case (MM_SUBMENU.MAIN): {
		// Logo
		var _i = (_gh / 2);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_sprite_ext(spr_logo, -1, _gw / 2, _i - 200, 2, 2, 0, c_white, 1);

		// Buttons
		sp_button.draw(_gw / 2, _i); _i += 72;
		mp_button.draw(_gw / 2, _i); _i += 72;
		settings_button.draw(_gw / 2, _i); _i += 72;
		quit_button.draw(_gw / 2, _i);
		draw_reset();
		draw_text(200, _gh / 2, get_text("menu_current_username"));
		
		// Username Field
		username_field.draw(200, _gh / 2 + 20)
		if (global.settings.username != username_field.stored_text && !username_field.selected) {
			global.settings.username = username_field.stored_text;
			save_json(global.settings, "settings.json");
		}

		// Version
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text(_gw, _gh, get_text("menu_version") + global.game_version);
		draw_reset();
	} break;
			
	// Multiplayer Select
	case (MM_SUBMENU.MP_SELECT): {
		prev_menu_state = MM_SUBMENU.MAIN;
		
		// Buttons
		var _i = (_gh / 2) - 72;
		host_button.draw(_gw / 2, _i); _i += 72;
		create_server_button.draw(_gw / 2, _i); _i += 72;
		join_button.draw(_gw / 2, _i); _i += 72;
		back_button.draw(_gw / 2, _i);
		
		// Return to title if ESC is pressed.
		if (keyboard_check_pressed(vk_escape)) {
			menu_state = MM_SUBMENU.MAIN;
		}
	} break;

	// MP Join
	case (MM_SUBMENU.MP_JOIN): {
		// Draw Text Field
		ip_field.draw(_gw / 2, _gh / 2);
		
		// Run enter action if ENTER is pressed
		if (keyboard_check_pressed(vk_enter)) {
			method_call(ip_field.accept, []);
		}
		
		// Run cancel action if ESC is pressed.
		if (keyboard_check_pressed(vk_escape)) {
			method_call(ip_field.cancel, []);
		}
	} break;
	
	// Settings
	case (MM_SUBMENU.SETTINGS): {
		draw_settings_menu();
	} break;
	
	// World Select
	case (MM_SUBMENU.WORLD_SELECT): {
		// Reset creation settings.
		global.default_gm = 0;
		global.maptype = 0;
		
		// Use stored load argument to determine what previous menu is.
		prev_menu_state = (obj_control.game_type == 0) ? MM_SUBMENU.MAIN : MM_SUBMENU.MP_SELECT;
		sel_play_world_button.text = (obj_control.game_type == 0) ? "menu_worldselect_play" : "menu_worldselect_host";
		
		// Return to previous menu if ESC is pressed.
		if (keyboard_check_pressed(vk_escape)) {
			menu_state = prev_menu_state;
			world_selection_panel.ceiling = 0;
		}
			
		// Draw save file list.
		draw_reset();
		world_selection_panel.panel_height = _gh - 130;
		world_selection_panel.draw(_gw / 2 - 500, 50);
		
		// Draw Header
		draw_rectangle_color(0, 0, _gw, 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_gw / 2, 25, get_text("menu_worldselect_head"));
		
		// Draw Footer
		draw_rectangle_color(0, _gh - 80, _gw, _gh, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
		back_button.draw(136, _gh - 40);
		delete_world_button.draw(_gw / 2 - 264, _gh - 40);
		rename_world_button.draw(_gw / 2, _gh - 40);
		copy_world_button.draw(_gw / 2 + 264, _gh - 40);
		create_world_button.draw(_gw / 2 + 528, _gh - 40);
	} break;
	
	// World Creation
	case (MM_SUBMENU.WORLD_CREATE): {
		// Return to world selection if ESC is pressed.
		if (keyboard_check_pressed(vk_escape)) {
			world_name_field.stored_text = "";
			world_seed_field.stored_text = "";
			menu_state = MM_SUBMENU.WORLD_SELECT;
		}
		
		// Draw input fields and text
		draw_text(_gw / 2 - 262, _gh / 2 - 190, get_text("menu_worldcreate_name"));
		world_name_field.draw(_gw / 2 - 262, _gh / 2 - 170);
		draw_text(_gw / 2 - 262, _gh / 2 - 108, get_text("menu_worldcreate_seed"));
		world_seed_field.draw(_gw / 2 - 262, _gh / 2 - 88);
		
		// Draw buttons
		world_create_gmtoggle_button.draw(_gw / 2, _gh / 2);
		world_create_mttoggle_button.draw(_gw / 2, _gh / 2 + 72);
		back_button.draw(_gw / 2 - 134, _gh / 2 + 144);
		world_create_button.draw(_gw / 2 + 134, _gh / 2 + 144);
		
		// Update text
		world_create_mttoggle_button.text = get_text("menu_worldcreate_mttoggle") + get_text((global.map_type) ? "menu_worldcreate_lab" : "menu_worldcreate_normal");
		world_create_gmtoggle_button.text = get_text("menu_worldcreate_gmtoggle") + get_text((global.default_gm) ? "menu_worldcreate_sandbox" : "menu_worldcreate_survival");
		
		// Update hover text
		world_create_mttoggle_button.hover_text = global.map_type ? "menu_worldcreate_lab_hover" : "menu_worldcreate_normal_hover";
		world_create_gmtoggle_button.hover_text = global.default_gm ? "menu_worldcreate_sandbox_hover" : "menu_worldcreate_survival_hover";
	}
}