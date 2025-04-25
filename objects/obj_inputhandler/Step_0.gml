/// @description Read User Input
// Do not accept user input if paused
if (global.paused) {
	exit;
}

// Get Current Build Chunk
var _tschunk = client_get_chunk(obj_selector.x, obj_selector.y);
if (_tschunk != noone) {
	// Get the tilemap corresponding to the build layer.
	if (floor_mode) {
		build_tm = _tschunk.ftm;
	}
	else {
		build_tm = _tschunk.stm;
	}
}

// Camera Management
if (global.player_control) {
	if ((mouse_wheel_down() || keyboard_check_pressed(global.settings.camera_zoom_out_bind)) && camera_zoom < 2) {
		// Zoom Out
		camera_zoom += 0.1;
	}
	if ((mouse_wheel_up() || keyboard_check_pressed(global.settings.camera_zoom_in_bind)) && camera_zoom > 0.5) {
		// Zoom In
		camera_zoom -= 0.1;
	}
	if (mouse_check_button_pressed(3) || keyboard_check_pressed(global.settings.camera_zoom_reset_bind)) {
		// Reset Zoom
		camera_zoom = 1;
	}
}

// Toggle Debug Mode
if (keyboard_check_pressed(vk_f3) && global.player_control) {
	debug_enabled = !debug_enabled;
}

// Toggle Chunk Grid
if (keyboard_check_pressed(vk_f9) && global.player_control) {
	show_chunks = !show_chunks;
}
	
// Toggle Tilegrid
if (keyboard_check_pressed(vk_f5) && global.player_control) {
	layer_set_visible("Tilegrid", !layer_get_visible("Tilegrid"));
}
	
// Reload all client chunks
if (keyboard_check_pressed(vk_f10) && global.player_control) {
	instance_destroy(obj_c_chunk);
}

// Toggle Chat
if (keyboard_check_pressed(global.settings.chat_bind) && global.player_control) {
	obj_chathandler.chat_enabled = true;
	keyboard_lastchar = "";
	global.player_control = false;
}
if (keyboard_check_pressed(vk_escape) && obj_chathandler.chat_enabled) {
	obj_chathandler.chat_enabled = false;
	global.player_control = true;
	keyboard_clear(vk_escape);
}
	
// Toggle Floor Mode
if (keyboard_check_pressed(global.settings.build_mode_bind) && global.player_control) {
	floor_mode = !floor_mode;
	client_send_data([4, 4, [floor_mode]]);
}
	
// Movement
var _moveinput = [0, 0]
if (global.player_control) {
	// Get input
	var _moveup = keyboard_check(global.settings.move_up_bind);
	var _moveleft = keyboard_check(global.settings.move_left_bind);
	var _movedown = keyboard_check(global.settings.move_down_bind);
	var _moveright = keyboard_check(global.settings.move_right_bind);
	
	// Get movement direction
	_moveinput[0] = _moveright - _moveleft;
	_moveinput[1] = _movedown - _moveup;
}
else {
	// If the player does not have control, cancel any move input.
	_moveinput = [0, 0];
}

if (!array_equals(_moveinput, move_last)) {
	// If our move order has changed, inform the server.
	client_send_data([4, 0, _moveinput]);
}
move_last = _moveinput;
	
// GUI Control
// Open player inventory
if (keyboard_check_pressed(global.settings.inventory_bind) && global.player_control) {
	if (obj_guihandler.current_gui = noone) {
		// If we aren't in another GUI, open the player inventory.
		obj_guihandler.current_gui = obj_playerchar.my_gui;
		keyboard_clear(global.settings.inventory_bind);
	}
}

// Click on Entity with GUI
// If the entity is within interaction range and shift is not held (to allow for building under entites), attempt to open its GUI.
if (mouse_check_button_pressed(1) && obj_selector.within_range && !(keyboard_check(vk_shift)) && collision_point(obj_selector.x, obj_selector.y, obj_c_entity, false, true) && global.player_control) {
	var _i =  collision_point(obj_selector.x, obj_selector.y, obj_c_entity, false, true)
	if (_i.has_gui) {
		// If there is a GUI, open it.
		obj_guihandler.current_gui = _i.my_gui;
		client_send_data([5, _i.server_id]);
		mouse_clear(1);
		keyboard_lastkey = vk_nokey;
	}
}

// Clear held item
// Only run if there is an item to clear and we are not in a GUI.
if (keyboard_check_pressed(vk_escape) && obj_playerchar.held_item.contents[0].stacksize > 0 && obj_guihandler.current_gui == noone) {
	client_send_data([4, 6, ["held_item", "player_inventory", 0, -1, -1]]);
	keyboard_clear(vk_escape);
}

// GUI Control
if (obj_guihandler.current_gui != noone) {
	// Disable player input.
	global.player_control = false;
	// If escape or the inventory key is pressed, close this GUI. 
	if (keyboard_check_pressed(vk_escape)) {
		obj_guihandler.current_gui = noone;
		client_send_data([5, "cancel"]);
		global.player_control = true;
		keyboard_clear(vk_escape);
	}
}
	
// Place tile or tileentity.
// Check that we are within interaction range and have something to try to place.
if (mouse_check_button(1) && global.player_control && obj_selector.within_range && obj_playerchar.held_item.contents[0].stacksize > 0) {
	// Reset cancel order.
	has_sent_build_cancel_order = false;
	if (mouse_check_button_pressed(1) || obj_selector.true_xp != obj_selector.x || obj_selector.true_yp != obj_selector.y) {
		// Send input information to server if we start building or move the cursor while building.
		client_send_data([4, 1, [true, obj_selector.x, obj_selector.y]]);
	}
}
// If we stop building or can no longer build, tell the server to stop if we haven't already.
else {
	if (!has_sent_build_cancel_order) {
		client_send_data([4, 1, [false, 0, 0]]);
		mouse_clear(1);
		has_sent_build_cancel_order = true;
	}
}
	
// Destroy tile or tileentity.
// Check that we are within interaction range.
if (mouse_check_button(2) && global.player_control && obj_selector.within_range) {
	// Reset cancel order.
	has_sent_break_cancel_order = false;
	if (mouse_check_button_pressed(2) || obj_selector.true_xp != obj_selector.x || obj_selector.true_yp != obj_selector.y) {
		// Send input information to server if we start trying to break something or move the cursor while trying to break something.
		client_send_data([4, 2, [true, obj_selector.x, obj_selector.y]]);
	}
	// Try to break a tile entity if one is on the cursor and we are not in floor mode.
	if (build_tm != undefined && !floor_mode && collision_point(obj_selector.x, obj_selector.y, obj_c_tileentity, false, true)) {
		// Tile Entity
		var _r = collision_point(obj_selector.x, obj_selector.y, obj_c_tileentity, false, true);
		obj_selector.destroy_progress += 1 / _r.hardness;
	}
	// Try to break the tile at the cursor on the current build layer.
	else if (build_tm != undefined && collision_point(obj_selector.x, obj_selector.y, build_tm, false, true)) {
		// Tile
		var _r = tilemap_get_at_pixel(build_tm, obj_selector.x, obj_selector.y); 
		obj_selector.destroy_progress += 1 / global.tile_id[_r].hardness;
	}
	// If none of the above apply, reset destroy progress.
	else {
		obj_selector.destroy_progress = 0;
	}
}
else {
	// If we stop trying to break things, tell the server if we haven't already.
	if (!has_sent_break_cancel_order) {
		client_send_data([4, 2, [false, 0, 0]]);
		obj_selector.destroy_progress = 0;
		mouse_clear(2);
		has_sent_break_cancel_order = true;
	}
}
	
// Pick up Items
// Check that we are close enough to pick an item up.
if (mouse_check_button(2) && global.player_control && obj_selector.within_range) {
	// Check if there is anything to pick up.
	var _i = collision_rectangle(mouse_x - 16, mouse_y - 16, mouse_x + 15, mouse_y + 15, obj_c_itemstack, false, true);
	if (_i != noone) {
		client_send_data([4, 3, [_i.server_id]]);
	}
}

// Pick up nearby items, or "sweep" for them.
if (keyboard_check(global.settings.sweep_bind) && global.player_control) {
	// Look for items.
	var _i = ds_list_create();
	collision_rectangle_list(obj_playerchar.x - 32, obj_playerchar.y - 32, obj_playerchar.x + 31, obj_playerchar.y + 31, obj_c_itemstack, false, true, _i, false);
	if (ds_list_size(_i) > 0) {
		for (var _j = 0; _j < ds_list_size(_i); _j++) {
			var _k = ds_list_find_value(_i, _j);
			client_send_data([4, 3, [_k.server_id]]);
		}
	}
	ds_list_destroy(_i);
}

// Drop Items
// Check that we have something to drop, are within interaction range, and the cursor is not on top of something.
if (keyboard_check_pressed(global.settings.drop_bind) && global.player_control && obj_selector.within_range && obj_playerchar.held_item.contents[0].stacksize > 0 && !collision_point(mouse_x, mouse_y, [obj_c_entity, _tschunk.stm], false, false)) {
	// If shift is pressed, drop everything.
	if (keyboard_check(vk_shift)) {
		client_send_data([4, 5, [obj_selector.x, obj_selector.y, true]]);
	}
	// Otherwise, just drop one.
	else {
		client_send_data([4, 5, [obj_selector.x, obj_selector.y, false]]);
	}
}

// Inventory Management
// Check if we are in a GUI and over an inventory slot.
if (current_hover[1] != -1 && obj_guihandler.current_gui != noone) {
	// Transfer Operation
	var _m = function() {
		var _i = obj_playerchar.held_item.contents[0];
		var _j = current_hover[0].contents[current_hover[1]];
		var _s = global.item_id[_j.item_id].maxsize - _j.stacksize;
		// If the item we are holding and the one in the slot is the same, try to combine the stacks.
		if (same_item(_i, _j)) {
			var _v = min(_i.stacksize, _s);
			client_send_data([4, 6, ["held_item", current_hover[0].name, 0, current_hover[1], _v]]);
		}
		// Otherwise, try to swap the stacks.
		else {
			client_send_data([4, 6, ["held_item", current_hover[0].name, 0, current_hover[1], -1]]);
		}
	}
	// Left Click Held
	if (mouse_check_button(1)) {
		// Shift Left Held
		if (keyboard_check(vk_shift)) {
			client_send_data([4, 6, [current_hover[0].name, "any", current_hover[1], -1, -1]]);
		}
		// Left Click
		else if (mouse_check_button_pressed(1)) {
			method_call(_m, []);
		}
	}
	// Right Click Held
	else if (mouse_check_button(2)) {
		var _i = obj_playerchar.held_item.contents[0];
		var _j = current_hover[0].contents[current_hover[1]];
		// If we right click on a stack while holding nothing, try to grab half of it.
		if (_i.stacksize <= 0 && mouse_check_button_pressed(2)) {
			var _split = ceil(_j.stacksize / 2)
			client_send_data([4, 6, [current_hover[0].name, "held_item", current_hover[1], -1, _split]]);
		}
		// If we are holding something try to deposit one of it.
		else if (_i.stacksize > 1) {
			// Check if we have moved the cursor since we last deposited something.
			var _hovermoved = (hover_slot_last != current_hover[1]);
			// If the slot is empty or has the same item, put one item in.
			if ((_j.stacksize <= 0 || same_item(_i, _j)) && _hovermoved) {
				client_send_data([4, 6, ["held_item", current_hover[0].name, 0, current_hover[1], 1]]);
			}
		}
		// If none of the above apply, do the same thing as left click.
		else if (mouse_check_button_pressed(2)) {
			method_call(_m, []);
		}
	}
	// Reset current hover.
	else {
		current_hover = [0, -1];
	}
}
hover_slot_last = current_hover[1];

// Crafting
// Check that there is a recipe we are over, we haven't moved, and can actually craft the item in question.
if (mouse_check_button(1) && current_recipe == last_recipe && current_recipe != -1 && inventory_has_items(obj_playerchar.player_inventory, global.recipe_registry[current_recipe].inputs)) {
	// Reset cancel order.
	has_sent_craft_cancel_order = false;
	// Get crafting time.
	var _ct = global.recipe_registry[current_recipe].time; 
	recipe_progress += 100 / _ct;
	// Tell the server we are trying to craft.
	if (mouse_check_button_pressed(1)) {
		client_send_data([4, 7, [current_recipe]]);
	}
	// Reset recipe progress when a craft is complete.
	if (recipe_progress >= 100) {
		recipe_progress = 0;
	}
}
// If we stop crafting or move off the recipe, inform the server if we havne't already.
else {
	if (!has_sent_craft_cancel_order) {
		recipe_progress = 0;
		client_send_data([4, 7, [-1]]);
		has_sent_craft_cancel_order = true;
		}
	}
last_recipe = current_recipe;

// Sandbox Item Selection
// Check that we are in sandbox mode and there is an item to select.
if (obj_gamehandler.player_gm && mouse_check_button_pressed(1) && current_sb_item_sel != -1) {
	client_send_data([4, 8, [current_sb_item_sel, keyboard_check(vk_shift)]]);
}

// Clear sandbox tile if there is one (also prevent a tile brush and item from being held at the same time).
if ((keyboard_check_pressed(vk_escape) && current_sb_tile_sel[1] != -1) || (instance_exists(obj_playerchar) && obj_playerchar.held_item.contents[0].stacksize > 0)) {
	current_sb_tile_sel[1] = -1;
	keyboard_clear(vk_escape);
}

// Place sandbox tile.
// Check that we are in sandbox mode and have a tile to place.
if (mouse_check_button(1) && global.player_control && obj_gamehandler.player_gm && current_sb_tile_sel[1] != -1) {
	// Reset cancel order.
	has_sent_sb_build_cancel_order = false;
	// If we start building or move the selector, inform the server.
	if (mouse_check_button_pressed(1) || obj_selector.true_xp != obj_selector.x || obj_selector.true_yp != obj_selector.y) {
		// Send input information to server.
		var _layer;
		switch (current_sb_tile_sel[0]) {
			case ts_ground: {
				_layer = 0;
			} break;
			case ts_floor: {
				_layer = 1;
			} break;
			case ts_solid: {
				_layer = 2;
			}
		}
		client_send_data([4, 9, [true, obj_selector.x, obj_selector.y, _layer, current_sb_tile_sel[1], sb_build_brushsize]]);
	}
}
// If we stop painting or no longer can, inform the server if we haven't already.
else {
	if (!has_sent_sb_build_cancel_order) {
		client_send_data([4, 9, [false, 0, 0, -1, -1, 1]]);
		mouse_clear(1);
		has_sent_sb_build_cancel_order = true;
	}
}