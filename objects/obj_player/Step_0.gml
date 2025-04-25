/// @description Player Management
event_inherited();

// Check if interact point is in range (ignore if in sandbox mode).
interact_in_range = distance_to_point(interact_x, interact_y) <= 256 || game_mode;

// Calculate direction
vx = move_h;
vy = move_v;

// Chunk Generation/Loading
var _cx1 = (floor(x / 512) * 512) - 2560;
var _cy1 = (floor(y / 512) * 512) - 2560;
// Index through nearby chunk locations.
for (var _j = 0; _j < 11; _j++) {
	for (var _k = 0; _k < 11; _k++) {
		// Get coordinates of next chunk.
		var _tx = _cx1 + (512 * _j);
		var _ty = _cy1 + (512 * _k);
		// If there is not a chunk here and we are not past the world border, load the chunk.
		if (!chunk_exists_at(_tx, _ty) && abs(_tx / 32) < 100016 && abs(_ty / 32) < 100016) {
			var _chunk_x = floor(_tx / 512);
			var _chunk_y = floor(_ty / 512);
			load_chunk(_chunk_x, _chunk_y);
		}
	}
}
	
// Tell Client to Update Position of Player if Moved
if (x != xprevious || y != yprevious) {
	server_send_data([10, x, y], my_client);
}

// Get current interact chunk and build tilemap.
ts_chunk = get_chunk(interact_x, interact_y);
if (ts_chunk != noone) {
	if (floor_mode) {
		build_tm = ts_chunk.ftm;
	}
	else {
		build_tm = ts_chunk.stm;
	}
}
else {
	build_tm = undefined;
}

// Variables for Interaction.
var _layer = (floor_mode) ? "ftm" : "stm";

// Reset destroy progress if interact point changes.
if (interact_x != prevint_x || interact_y != prevint_y) {
	destroy_progress = 0;
	sel_moved = true;
}
else {
	sel_moved = false;
}
prevint_x = interact_x;
prevint_y = interact_y;

// Place Tile or Tileentity
// Check that there is a build tilemap, we have something to place, are in interaction range, and are not over something.
if (build_tm != undefined && build_input && held_item.contents[0].stacksize > 0 && interact_in_range && (!collision_rectangle(interact_x - 16, interact_y - 16, interact_x + 16, interact_y + 16, obj_par_entity, false, false) || floor_mode) && !collision_point(interact_x, interact_y, build_tm, false, false) && !array_contains([3, 4], tilemap_get_at_pixel(ts_chunk.gtm, interact_x, interact_y))) {
	// Get item type.
	var _type = global.item_id[held_item.contents[0].item_id].item_type;
	// Tile
	if (_type == ITEMTYPES.TILE) {
		// Get tile and place it.
		var _tile = held_item.contents[0].item_id + 1;
		tilemap_set_at_pixel(build_tm, _tile, interact_x, interact_y);
		send_chunk_update([interact_x, interact_y, _layer, _tile]);
		// If we are in survival mode, decrement stack.
		if (!game_mode) {
			held_item.contents[0].stacksize--;
			send_inventory_update(0, held_item);
		}
	}
	// Tileentity
	else if (_type == ITEMTYPES.TILEENTITY && !floor_mode) {
		// Spawn in the tileentity.
		instance_create_layer(interact_x, interact_y + 16, "Server", global.item_id[held_item.contents[0].item_id].params.object);
		// If we are in survival, decrement stack.
		if (!game_mode) {
			held_item.contents[0].stacksize--;
			send_inventory_update(0, held_item);
		}
	}
}
// Sandbox Tile Brush
// Check that player is in sandbox mode and has something to place.
else if (build_input && game_mode && sb_tile != -1 && sel_moved && held_item.contents[0].stacksize <= 0) {
	// Get brush diameter and radius.
	var _d = sb_brush_size;
	var _r = _d / 2;
	// Get center of brush area.
	var _par = floor(_r) == _r;
	var _cx = _par ? interact_x - 16 : interact_x;
	var _cy = _par ? interact_y - 16 : interact_y;
	// Index through tiles in range.
	for (var _i = 0; _i < _d; _i++) {
		// Get x offset
		var _xo = (interact_x - floor(_r) * 32 + 32 * _i);
		for (var _j = 0; _j < _d; _j++) {
			// Get y offset.
			var _yo = (interact_y - floor(_r) * 32 + 32 * _j);
			// If tile is in radius of brush and there isn't a tileentity here, place the selected tile.
			var _dist = point_distance(_cx, _cy, _xo, _yo);
			if (_dist <= _r * 32 && !collision_point(_xo,  _yo - 16, obj_par_tileentity, false, false)) {
				sb_tile_layer[0] = variable_instance_get(get_chunk(_xo, _yo), sb_tile_layer[1]);
				if (tilemap_get_at_pixel(sb_tile_layer[0], _xo, _yo) != sb_tile) {
					tilemap_set_at_pixel(sb_tile_layer[0], sb_tile, _xo, _yo);
					send_chunk_update([_xo, _yo, sb_tile_layer[1], sb_tile]);
				}
			}
		}
	}
}

// Destroy Tile or Tileentity
// Check that the build tilemap exists and we are within range.
if (break_input && build_tm != undefined && interact_in_range) {
	if (place_meeting(interact_x, interact_y, obj_par_tileentity) && !floor_mode) {
		// Tile Entity
		var _r = collision_point(interact_x, interact_y, obj_par_tileentity, false, false);
		if (instance_exists(_r)) {
			// Get inventories of tile entity.
			var _d = _r.inventories;
			
			// Calculate destroy progress.
			destroy_progress += (game_mode) ? 100 : 1 / _r.hardness;
			
			// If destroy progress is 100, break this tileentity.
			if (destroy_progress >= 100) {
				// Give items to player.
				for (var _i = 0; _i < array_length(_r.returns); _i++) {
					// Get Drop Info
					var _chance = _r.returns[_i][1];
					// Add this drop to inventory if drop rate is 100% or "dice roll" lands.
					if (dice_roll(_chance)) {
						if (same_item(held_item.contents[0], _r.returns[_i][0]) && held_item.contents[0].stacksize < global.item_id[held_item.contents[0].item_id].maxsize) {
							inventory_add(held_item, _r.returns[_i][0], false, interact_x, interact_y);
						}
						else {
							inventory_add(player_inventory, _r.returns[_i][0], false, interact_x, interact_y);
						}
					}	
				}

				// Attempt to put anything that was in the tileentity's inventories in player inventory.
				for (var _i = 0; _i < array_length(_d); _i++) {
					for (var _j = 0; _j < _d[_i].slots; _j++) {
						inventory_add(player_inventory, itemstack_copy(_d[_i].contents[_j]), false, interact_x, interact_y);
					}
				}
				// Remove tileentity and reset destroy progress.
				instance_destroy(_r);
				destroy_progress = 0;
			}
		}
	}
	else if (collision_point(interact_x, interact_y, build_tm, false, false)) {
		// Tile
		// Get tile and calculate destroy progress.
		var _r =  tilemap_get_at_pixel(build_tm, interact_x, interact_y);
		if (_r != 0) {
			destroy_progress += (game_mode) ? 100 : 1 / global.tile_id[_r].hardness;
		}
		
		// If destroy progress reaches 100, destroy this tile.
		if (destroy_progress >= 100) {
			// Set tile to empty.
			tilemap_set_at_pixel(build_tm, 0, interact_x, interact_y);
			send_chunk_update([interact_x, interact_y, _layer, 0]);
			
			// Get tile drops and attempt to add them to inventory.
			var _drops = global.tile_id[_r].returns;
			for (var _i = 0; _i < array_length(_drops); _i++) {
				// Get Drop Info
				var _id = _drops[_i][0];
				var _amount = _drops[_i][1];
				var _chance = _drops[_i][2];
				// Add this drop to inventory if drop rate is 100% or "dice roll" lands.
				if (dice_roll(_chance)) {
					var _drop = new ItemStack(_id, _amount);
					if (same_item(held_item.contents[0], _drop) && held_item.contents[0].stacksize < global.item_id[held_item.contents[0].item_id].maxsize) {
						inventory_add(held_item, _drop, false, interact_x, interact_y);
					}
					else {
						inventory_add(player_inventory, _drop, false, interact_x, interact_y);
					}
				}	
			}
			destroy_progress = 0;
		}
	}
}	
else {
	// Reset progress if we aren't doing anything or were interrupted.
	destroy_progress = 0;
}
	
// Handcrafting
// Chcek that there is a current recipe and client did not move off of it.
if (current_recipe != -1 && current_recipe == last_recipe) {
	// Fetch recipe info.
	var _recipe = global.recipe_registry[current_recipe];
	var _time = _recipe.time;
	
	// Increment crafting progress.
	craft_progress += 1 / _time;
	
	// If craft is finished and we have the items, complete the recipe.
	if (craft_progress >= 1 && inventory_has_items(player_inventory, _recipe.inputs)) {
		// Remove inputs and give outputs (This should be its own function).
		for (var _i = 0; _i < array_length(_recipe.inputs); _i++) {
			inventory_subtract(player_inventory, _recipe.inputs[_i]);
		}
		for (var _i = 0; _i < array_length(_recipe.outputs); _i++) {
			inventory_add(player_inventory, _recipe.outputs[_i]);
		}
		
		// Reset craft progress.
		craft_progress = 0;
	}
}
else {
	// Reset progress if we aren't doing anything or were interrupted.
	craft_progress = 0;
}
last_recipe = current_recipe;

// Client Entity Update
// Get nearby entities.
var _list = ds_list_create();
collision_rectangle_list(x - 4096, y - 4096, x + 4096, y + 4096, obj_par_entity, false, true, _list, false);
// Check if anything has changed (this isn't optimal).
if (string(_list) != string(last_entity_selection)) {
	// Look for new entities.
	var _new = [];
	for (var _i = 0; _i < ds_list_size(_list); _i++) {
		var _a = ds_list_find_value(_list, _i);
		var _b = ds_list_find_index(last_entity_selection, _a);
		if (_b == -1) {
			array_insert(_new, array_length(_new), _a);
		}
	}
	// Tell clients to add new entites to their game world.
	for (var _i = 0; _i < array_length(_new); _i++) {
		var _a = _new[_i];
		var _sock = my_client;
		with (_a) {
			server_send_data([6, x, y, object_get_name(object_index), string(id)], _sock);
			method_call(establish_info, [_sock]);
		}
	}
}
ds_list_copy(last_entity_selection, _list);
ds_list_destroy(_list);