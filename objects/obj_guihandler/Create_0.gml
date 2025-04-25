/// @description Variables
current_gui = noone; // Current GUI
// Mouse coordinates relative to GUI surface.
gui_mouse_x = 0;
gui_mouse_y = 0;
// Location of GUI surface relative to window.
gui_surf_x = 0; 
gui_surf_y = 0;
server_ups = 0; // Server Tickrate
ping = 0; // Latency with Server

// Sandbox tile button.
tile_brush_button = new Button(64, 64, "", function() {
	if (obj_playerchar.held_item.contents[0].stacksize <= 0) {
		// Only allow this menu to be opened if player isn't holding anything.
		current_gui = tile_brush_menu;
	}
}, "sb_tile_hover");

// Toolbar in tile menu.
tile_brush_toolbar = new Toolbar(426, 32, ["sb_tile_ground", "sb_tile_floor", "sb_tile_solid"]);

// Slider for brush size.
tile_brush_slider = new Slider(362, "sb_tile_brush", function() {
	// Translate slider position to brush size.
	var _out = round(obj_guihandler.tile_brush_slider.position * 63);
	
	// Update brush size and UI.
	obj_guihandler.tile_brush_slider.position = _out / 63;
	obj_guihandler.tile_brush_slider.label = get_text("sb_tile_brush") + string(_out + 1);
	obj_inputhandler.sb_build_brushsize = _out + 1;
});

// Tile brush GUI
tile_brush_menu = new GUI(0, 0, 426, 216, function() {
	tile_brush_toolbar.draw(0, 0);
	// Get current tab.
	var _tm = ts_ground;
	switch (tile_brush_toolbar.selected_tab) {
		case 0: {
			_tm = ts_ground;
		} break;
		case 1: {
			_tm = ts_floor;
		} break;
		case 2: {
			_tm = ts_solid;
		} break;
	}
	// Draw selection options.
	var _tilematrix = draw_sandbox_tile_matrix(4, 36, 30, 3, _tm);
	var _over = sandbox_tile_mouse_map(_tilematrix, _tm);
	if (mouse_check_button(1)) {
		obj_inputhandler.current_sb_tile_sel = [_tm, _over];
	}
	// Draw brush slider.
	obj_guihandler.tile_brush_slider.label = get_text("sb_tile_brush") + string(obj_inputhandler.sb_build_brushsize);
	tile_brush_slider.draw(32, 168);
});