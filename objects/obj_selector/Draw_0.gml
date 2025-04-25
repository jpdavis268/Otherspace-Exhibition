/// @0description Render Tile Selector
// Exit if paused
if (global.paused) {
	exit;
}

// Draw selector if the chunk it is on exists.
if (client_chunk_exists_at(x, y)) {
	// Get held item and its type.
	var _held = obj_playerchar.held_item.contents[0];
	var _type = global.item_id[_held.item_id].item_type;
	// Set color based on whether operation is performable (yellow for yes, red for no).
	var _color;
	// Check that we are within interaction range, and are not over something that would block placement if we are trying to place something.
	if (within_range && (((_type != ITEMTYPES.TILE && _type != ITEMTYPES.TILEENTITY) || _held.stacksize <= 0) || (!collision_point(x, y, obj_inputhandler.build_tm, false, false) && !array_contains([3, 4], tilemap_get_at_pixel(client_get_chunk(x, y).gtm, x, y)) && !collision_rectangle(x - 16, y - 16, x + 16, y + 16, [obj_c_entity, obj_playerchar], false, false)))) {
		_color = c_yellow;
	}
	else {
		_color = c_red;
	}
	if (_held.stacksize > 0 && _type == ITEMTYPES.TILE) {
		// If player is trying to build with a tile, draw tile
		draw_set_alpha(0.5);
		if (obj_inputhandler.floor_mode) {
			draw_tile(ts_floor, _held.item_id + 1, 0, x - 16, y - 16);
		}
		else {
			draw_tile(ts_solid, _held.item_id + 1, 0, x - 16, y - 16);
		}
		draw_set_alpha(0.2);
		draw_rectangle_color(x - 16, y - 16, x + 15, y + 15, _color, _color, _color, _color, false);
		draw_set_alpha(1);
	}
	else if (_held.stacksize > 0 && _type == ITEMTYPES.TILEENTITY) {
		// If player is trying to place a tile entity, draw that entity's sprite
		// If we are in floor mode, set color to red, as we cannot place entity.
		if (obj_inputhandler.floor_mode) {
			_color = c_red;
		}
		draw_sprite_ext(global.item_id[_held.item_id].params.sprite, 0, x, y + 16, 1, 1, 0 , _color, 1);
	}
	else if (obj_inputhandler.current_sb_tile_sel[1] != -1) {
		// If player is trying to build with a sandbox brush, draw tiles.
		// Get diameter and radius.
		var _d = obj_inputhandler.sb_build_brushsize;
		var _r = _d / 2;
		// Get center of brush circle.
		var _par = floor(_r) == _r;
		var _cx = _par ? x - 16 : x;
		var _cy = _par ? y - 16 : y;
		for (var _i = 0; _i < _d; _i++) {
			// Get x offset from selector.
			var _xo = (x - floor(_r) * 32 + 32 * _i);
			for (var _j = 0; _j < _d; _j++) {
				// Get y offset from selector.
				var _yo = (y - floor(_r) * 32 + 32 * _j);
				// Only draw tile if within brush circle.
				var _dist = point_distance(_cx, _cy, _xo, _yo);
				if (_dist <= _r * 32) {
					draw_set_alpha(0.5);
					draw_tile(obj_inputhandler.current_sb_tile_sel[0], obj_inputhandler.current_sb_tile_sel[1], 0, _xo - 16, _yo - 16);
					draw_set_alpha(0.2);
					draw_rectangle_color(_xo - 16, _yo - 16, _xo + 15, _yo + 15, _color, _color, _color, _color, false);
				}
			}
		}
		draw_set_alpha(1);
	}
	else {
		// Draw Tile Selector
		draw_rectangle_color(x - 16, y - 16, x + 15, y + 15, _color, _color, _color, _color, true);
	}
}
	
// Show destroy progress if there is any.
if (destroy_progress != 0) {
	draw_healthbar(x - 25, y + 20, x + 25, y + 30, destroy_progress, c_black, c_lime, c_lime, 0, true, true);
}