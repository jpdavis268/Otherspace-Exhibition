/// @description Initialize States and Structs
// Submenus
enum MM_SUBMENU {
	MAIN,
	MP_SELECT,
	MP_JOIN,
	WORLD_SELECT,
	WORLD_CREATE,
	SETTINGS,
}
	
prev_menu_state = MM_SUBMENU.MAIN; // Previous submenu.
menu_state = MM_SUBMENU.MAIN; // Current submenu.
global.default_gm = 0; // Initialize default gamemode variable.
global.map_type = 0; // Initialize map type variable.

// Global
back_button = new Button(256, 64, "menu_back", function() { // Back 
	menu_state = prev_menu_state;
});

// Main Menu
sp_button = new Button(256, 64, "menu_sp", function() { // Singleplayer 
	obj_control.game_type = 0;
	prev_menu_state = menu_state;
	menu_state = MM_SUBMENU.WORLD_SELECT;
});
mp_button = new Button(256, 64, "menu_mp", function() { // Multiplayer
	prev_menu_state = menu_state;
	menu_state = MM_SUBMENU.MP_SELECT;
});
settings_button = new Button(256, 64, "menu_settings", function() { // Settings
	prev_menu_state = menu_state;
	menu_state = MM_SUBMENU.SETTINGS;
});
quit_button = new Button(256, 64, "menu_exit_game", function() { // Exit Game
	game_end();
});
username_field = new InputField(256, global.settings.username); // Username Input

// MP Menu
host_button = new Button(256, 64, "menu_mp_host", function() { // Host Game
	obj_control.game_type = 1;
	prev_menu_state  = menu_state;
	menu_state = MM_SUBMENU.WORLD_SELECT;
});
create_server_button = new Button(256, 64, "menu_mp_dedicated", function() { // Create Dedicated Server
	obj_control.game_type = 2;
	prev_menu_state = menu_state;
	menu_state = MM_SUBMENU.WORLD_SELECT;
});
join_button = new Button(256, 64, "menu_mp_join", function() { // Join Server
	obj_control.game_type = 3;
	prev_menu_state = menu_state;
	menu_state = MM_SUBMENU.MP_JOIN;
});

// Multiplayer Join IP Entry
ip_field = new TextField(500, 100, "menu_mp_join_ip_prompt", function() { // IP Input
		global.connect_to = ip_field.stored_text;
		ip_field.stored_text = "";
		ip_field.draw.input_position = 0;
		ip_field.draw.input_position_offset = 0;
		room_goto(rm_game);
	}, function() {
		ip_field.stored_text = "";
		ip_field.draw.input_position = 0;
		ip_field.draw.input_position_offset = 0;
		prev_menu_state = menu_state;
		menu_state = MM_SUBMENU.MP_SELECT;
});

// World Selection
selected_save = undefined; // Which save we are over.

// Get saves
saves = get_saves(); // Fetch save data.

// Load save information
save_info = retrieve_save_manifests(saves); // Get save info.

// World creation button.
create_world_button = new Button(256, 64, "menu_worldselect_create", function() {
	prev_menu_state = menu_state;
	menu_state = MM_SUBMENU.WORLD_CREATE;
});

// World deletion button.
delete_world_button = new Button(256, 64, "menu_worldselect_delete", function() {
	// Ask player to confirm they want to delete the world.
	global.confirm_dialogue = new ConfirmDialogue("menu_worldselect_delete_confirm", function () {
		// If there is a save to delete, delete it.
		if (!is_undefined(obj_menu.selected_save)) {
			directory_destroy("saves/" + obj_menu.selected_save);
		
			// Reload save information.
			saves = get_saves();
			save_info = retrieve_save_manifests(saves);
			world_selection_panel.height = array_length(saves) * 100 + 100;
		}
	});
});

// World renaming button.
rename_world_button = new Button(256, 64, "menu_worldselect_rename", function() {
	if (is_undefined(obj_menu.selected_save)) {
		exit;
	}
	
	// Request player to input a new world name.
	global.confirm_dialogue = new TextField(1, 1, "menu_worldselect_rename_prompt", function() {
		var _newname = global.confirm_dialogue.stored_text;
		while (directory_exists("saves/" + _newname)) {
			_newname += "_";
		}
			
		// For some reason GMS doesn't have a way of renaming folders,
		// and since the only library I could find breaks the file system code the best solution
		// I could come up with was copying over the files to a new directory and deleting the old one.
		var _newdir = "saves/" + _newname;
		directory_create(_newdir);
			
		// Get all files.
		var _olddir = "saves/" + obj_menu.selected_save;
		var _tocopy = [];
		var _nextfile = file_find_first(_olddir + "/*", fa_none);
		while (_nextfile != "") {
			array_push(_tocopy, _nextfile);
			_nextfile = file_find_next();
		}
		file_find_close();
	
		// Copy all files
		for (var _i = 0; _i < array_length(_tocopy); _i++) {	
			file_copy("saves/" + obj_menu.selected_save + "/" + _tocopy[_i], _newdir + "/" +  _tocopy[_i]);
		}
			
		// Delete old directory.
		directory_destroy(_olddir);
	
		// Reload saves.
		saves = get_saves();
		save_info = retrieve_save_manifests(saves);
		global.confirm_dialogue = undefined;
	},
	function() {
		global.confirm_dialogue = undefined;
	});
});

// World copying button.
copy_world_button = new Button(256, 64, "menu_worldselect_copy", function() {
	// Exit if there is nothing to copy.
	if (is_undefined(obj_menu.selected_save)) {
		exit;
	}
	
	// Generate a new name
	var _newname = "saves/" + obj_menu.selected_save;
	
	// Make sure there are not any saves with the name we are about to give the new copy.
	while (directory_exists(_newname)) {
		_newname += "_";
	}
	
	// Create a new directory.
	directory_create(_newname);
	
	// Get all files.
	var _olddir = "saves/" + obj_menu.selected_save + "/*";
	var _tocopy = [];
	var _nextfile = file_find_first(_olddir, fa_none);
	while (_nextfile != "") {
		array_push(_tocopy, _nextfile);
		_nextfile = file_find_next();
	}
	file_find_close();
	
	// Copy all files
	for (var _i = 0; _i < array_length(_tocopy); _i++) {	
		file_copy("saves/" + obj_menu.selected_save + "/" + _tocopy[_i], _newname + "/" +  _tocopy[_i]);
	}
	
	// Reload saves.
	saves = get_saves();
	save_info = retrieve_save_manifests(saves);
	world_selection_panel.height = array_length(saves) * 100 + 100;
});

// Play Button
sel_play_world_button = new Button(128, 64, "menu_worldselect_host", function() {
	if (!is_undefined(obj_menu.selected_save)) {
		global.current_save = "saves/" + obj_menu.selected_save;
		room_goto(rm_game);
	}
});

// Save List
world_selection_panel = new ScrollableSurface(1000, array_length(saves) * 100 + 100, 500, function() {
	static _sel_index = 0;
	var _surfx = display_get_gui_width() / 2 - 500;
	
	for (var _i = 0; _i < array_length(obj_menu.saves); _i++) {
		var _y = _i * 100;
		var _wy = _y + 50 - world_selection_panel.ceiling;
		// Handle user selection
		if (mouse_check_button_pressed(1)
		&& mouse_is_over(_surfx, 50, _surfx + world_selection_panel.width, 50 + world_selection_panel.panel_height, true)
		&& mouse_is_over(_surfx, _wy, _surfx + world_selection_panel.width - 164, _wy + 100, true)) {
			_sel_index = _i;
		}
		
		// Draw contents
		if (_sel_index == _i) {
			draw_set_alpha(0.5);
			draw_rectangle(0, _y, world_selection_panel.width - 10, _y + 100, false);
			draw_set_alpha(1);
		}
		
		// This is somewhat ugly, but will do for now.
		draw_set_font(fnt_main_large);
		draw_text(0, _y, obj_menu.saves[_i]);
		draw_set_font(fnt_main);
		draw_text(0, _y + 32, save_info[_i].date);
		draw_text(0, _y + 48, save_info[_i].version);
		draw_text(0, _y + 64, save_info[_i].playtime);
		
		// Draw play button and update selection index if selected.
		if (_sel_index == _i) {
			obj_menu.selected_save = saves[_i];
			var _panelsurf = surface_get_target();
			surface_reset_target();
			sel_play_world_button.draw(_surfx + 918, _y + 100 - world_selection_panel.ceiling, window_get_height() - 80);
			surface_set_target(_panelsurf);
		}
	}
});

// World Creation
world_name_field = new InputField(524); // Name Input
world_seed_field = new InputField(524); // Seed Input
// Gamemode Toggle
world_create_gmtoggle_button = new Button(524, 64, "menu_worldcreate_gmtoggle", function() {
	global.default_gm = !global.default_gm;
});
// Map Type Toggle
world_create_mttoggle_button = new Button(524, 64, "menu_worldcreate_mttoggle", function() {
	global.map_type = !global.map_type;
});
// Create World Button
world_create_button = new Button(256, 64, "menu_worldcreate_create", function() {
	// If the player input a seed, convert it to a number and set the random seed to it.
	if (string_length(world_seed_field.stored_text) > 0) {
		random_set_seed(generate_number(world_seed_field.stored_text));
	}
	// If they didn't, generate one.
	else {
		randomize();
	}
	
	// Create a new save file.
	var _newsave = "saves/" + file_name_verify(obj_menu.world_name_field.stored_text);
	var _created = false;
	var _i = 0;
	while (!_created) {
		if (directory_exists(_newsave)) {
			_i++;
			_newsave += "_";
		}
		else {
			directory_create(_newsave);
			_created = true;
		}
	}
	// Generate manifest
	// Set date based on user preference.
	var _date = (global.settings.date_format) ? get_date_mmdd() : date_date_string(date_current_datetime());
	save_json({
			date : _date,
			version : global.game_version,
			playtime : "0hrs 0mins"
		},
		_newsave + "/manifest.json"
	);
	
	// Generate world ID (Saving it to a random text file probably isn't the cleanest way of doing this,
	// but is the best avaliable given the current save data format and is (probably) futureproof).
	// This system generates its time based on the current second (clamped at a high value to prevent the number
	// from going over the 64-bit limit in about 30000 years. You're welcome, gleepzorp) and adds another random number to the end, generating a base string that should
	// HOPEFULLY be unique to that server. 
	var _timestamp = int64(date_second_span(date_current_datetime(), date_create_datetime(2024, 12, 31, 23, 59, 59))) % 999999999999;
	var _id = string(_timestamp) + string(irandom(999999));
	var _idfile = file_text_open_write(_newsave + "/saveid");
	file_text_write_string(_idfile, _id);
	file_text_close(_idfile);
	
	// Set current save to the one we just created and go to game.
	global.current_save = _newsave;
	room_goto(rm_game);
});