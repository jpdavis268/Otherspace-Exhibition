/// @description Draw HUD Elements
// Store GUI Dimensions
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _mx = window_mouse_get_x();
var _my = window_mouse_get_y();

// Draw GUI if we are supposed to.
if (current_gui != noone) {
	// Update GUI mouse coordinates.
	gui_mouse_x = (_mx - ((_gw / 2) - current_gui.guiwidth / 2));
	gui_mouse_y = (_my - ((_gh / 2) - current_gui.guiheight / 2));
	
	// GUI Dimensions
	var _cgx = current_gui.gx;
	var _cgy = current_gui.gy;
	var _cgw = current_gui.guiwidth;
	var _cgh = current_gui.guiheight;
	
	// Update GUI surface position.
	gui_surf_x = (_gw / 2) + _cgx - floor(_cgw / 2);
	gui_surf_y = (_gh / 2) + _cgy - floor(_cgh / 2);
	
	// Draw the GUI according to its parameters.
	var _i = surface_create(_cgw, _cgh);
	surface_set_target(_i);
	draw_gui_box(_cgw, _cgh);
	method_call(current_gui.args, []);
	surface_reset_target();
	draw_surface(_i, gui_surf_x, gui_surf_y);
	surface_free(_i);
	// Draw held item if there is one.
	if (instance_exists(obj_playerchar) && obj_playerchar.held_item.contents[0].stacksize > 0) {
		draw_inventory_matrix(window_mouse_get_x(), window_mouse_get_y(), obj_playerchar.held_item, 1, true);
	}
	// Draw item name box if over one.
	if (obj_inputhandler.current_hover[1] != -1 && obj_inputhandler.current_hover[0].contents[obj_inputhandler.current_hover[1]].stacksize > 0) {
		var _item = obj_inputhandler.current_hover[0].contents[obj_inputhandler.current_hover[1]];
		var _name = global.item_id[_item.item_id].name;
		draw_text_box(_mx, _my + 12, get_text(_name));
	}
	// Draw sandbox item name if over one.
	else if (obj_inputhandler.current_sb_item_sel != -1) {
		// Sandbox item menu.
		var _name = global.item_id[obj_inputhandler.current_sb_item_sel].name;
		draw_text_box(_mx, _my + 12, get_text(_name));
	}
	// Draw recipe info if over one.
	if (obj_inputhandler.current_recipe != -1) {
		var _recipe = global.recipe_registry[obj_inputhandler.current_recipe];
		draw_recipe_info(_mx, _my + 12, _recipe);
	}
}
else {
	// Cleanup
	obj_inputhandler.current_recipe = -1;
	
	// Draw held item if there is one.
	if (instance_exists(obj_playerchar) && obj_playerchar.held_item.contents[0].stacksize > 0) {
		draw_inventory_matrix(window_mouse_get_x(), window_mouse_get_y(), obj_playerchar.held_item, 1, true);
	}
}
	
// Show crafting progress if we are crafting something.
if (obj_inputhandler.recipe_progress != 0) {
	draw_healthbar(window_mouse_get_x(), window_mouse_get_y(), window_mouse_get_x() + 50, window_mouse_get_y() + 10, obj_inputhandler.recipe_progress, c_black, c_lime, c_lime, 0, true, true);
}	

// Game Info
var _i = 0;
draw_text(0, _i, "Otherspace " + global.game_version); _i += 20;
draw_text(0, _i, string(obj_gamehandler.player_username) + ", " + string(ping) + "ms"); _i += 20;
draw_text(0, _i, "FPS/UPS: " + string(fps) + "/" + string(server_ups)); _i += 20;
draw_text(0, _i, get_text("hud_day") + " " + string(obj_gamehandler.day) +", " + obj_gamehandler.time + ", " + obj_gamehandler.day_phase); _i += 20;
var _layer;
if (obj_inputhandler.floor_mode) {
	_layer = get_text("hud_floor");
}
else {
	_layer = get_text("hud_normal");
}
draw_text(0, _i, get_text("hud_build_mode") + ": " + string(_layer) + " (" + get_text("hud_bm_press") + " " + chr(global.settings.build_mode_bind) + " " + get_text("hud_bm_to_toggle") + ")"); _i += 20;

// Fetch player coordinates
var _x = 0, _y = 0;
if (instance_exists(obj_playerchar)) {
	_x = obj_playerchar.x;
	_y = obj_playerchar.y;
}

// Debug Information
if (obj_inputhandler.debug_enabled) {
	draw_set_halign(fa_center)
	draw_text(_gw / 2, 0, get_text("hud_debug_info_enabled"));
	draw_set_halign(fa_left);
	draw_text(0, _i, get_text("hud_light_level") + ": " + string(obj_lighthandler.light_level)); _i += 20;
	draw_text(0, _i, get_text("hud_player_coordinates_engine") + ": " + string(_x) + ", " + string(_y)); _i += 20;
	draw_text(0, _i, get_text("hud_network_sent") + ": " + string(obj_gamehandler.data_sent) +"KB/s, " + get_text("hud_network_received") + ": " + string(obj_gamehandler.data_received) + "KB/s"); _i += 20;
	draw_text(0, _i, get_text("hud_currentsave") + global.current_save); _i += 20;
	draw_text(0, _i, string("{0}{1}", get_text("menu_worldcreate_gmtoggle"), get_text(obj_gamehandler.player_gm ? "menu_worldcreate_sandbox" : "menu_worldcreate_survival")));
}

// Draw coordinates
draw_set_halign(fa_right);
draw_text(_gw, 0, "x: " + string(_x / 32) + ", y:" + string(_y / 32));
draw_reset();

// Sandbox Tile Brush Menu Button (only draw if in sandbox mode)
if (current_gui == noone && obj_gamehandler.player_gm) {
	tile_brush_button.draw(64, _gh - 64);
	draw_sprite(spr_sbtilebrush, 0, 64, _gh - 64);
}