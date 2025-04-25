
/**
 * Define a new GUI.
 *
 * @param {real} _x x-offset from center of screen.
 * @param {real} _y y-offset from center of screen.
 * @param {real} _width Width of GUI.
 * @param {real} _height Height of GUI.
 * @param {function} _args What to draw on GUI.
 */
function GUI(_x, _y, _width, _height, _args) constructor {
	gx = _x;
	gy = _y;
	guiwidth = _width;
	guiheight = _height;
	args = _args;
}
	

/**
 * Create a new client side "display" inventory.
 *
 * @param {real} [_slots] Number of slots in inventory.
 * @param {string} [_name] Name of inventory (on server).
 */
function DisplayInventory(_slots = 1, _name = "null") constructor {
	slots = _slots;
	contents = array_create(_slots, new ItemStack());
	name = _name;
}	


/**
 * Draw background of a GUI.
 *
 * @param {real} _width GUI width.
 * @param {real} _height GUI height.
 */
function draw_gui_box(_width, _height) {
	draw_rectangle_color(0, 0, _width, _height, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
}
	
/**
 * Draw recipe matrix for client side selection.
 *
 * @param {real} _x x-coordinate of top left corner.
 * @param {real} _y y-coordinate of top left corner.
 * @param {real} _squares Number of squares in matrix.
 * @param {real} _rows Number of rows in matrix.
 * @returns {array<array<real>>} Locations of cells.
 */
function draw_crafting_matrix(_x, _y, _squares, _rows,) {
	var _cols = ceil(_squares / _rows);
	var _index = 0;
	var _cm = [];
	// May want to make a color registry at some point.
	var _norcol = make_color_rgb(32, 32, 32);
	// Index through rows and columns to draw squares in a grid.
	for (var _i = 1; _i <= _rows; _i++) {
		for (var _j = 1; _j <= _cols; _j++ ) {
			// Ensure we have not gone outside the bounds of the grid.
			if (_index <= _squares) {
				var _cx = _x + ((_j - 1) * 42);
				var _cy = _y + ((_i - 1) * 42);
				// Draw recipe in slot.
				if (_index < array_length(global.recipe_registry)) {
					var _recipe = global.recipe_registry[_index];
					var _todraw = _recipe.outputs[0].item_id;
					var _col = c_dkgray;
					// Check that we have items and shade cell accordingly.
					if (inventory_has_items(obj_playerchar.player_inventory, _recipe.inputs)) {
						_col = c_gray;
					}
					// Draw tile and recipe icon.
					draw_roundrect_color(_cx, _cy, _cx + 39, _cy + 39, _col, _col, false);
					draw_tile(ts_itemmap, _todraw + 1, -1, _cx + 4, _cy + 4);
				}
				else {
					draw_roundrect_color(_cx, _cy, _cx + 39, _cy + 39, _norcol, _norcol, false);
				}
				// Store cell information and increase index.
				var _cmt = [_cx, _cy]
				_cm[_index] = _cmt;
				_index++;
			}
		}
	}
	return _cm;
}

/**
 * Determine if mouse is over a slot in the matrix.
 *
 * @param {array} _mapping Coordinates of slots.
 * @returns {real} Slot mouse is over, or -1 if it isn't over any.
 */
function crafting_matrix_mouse_map(_mapping) {
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.2);
	var _mc = -1;
	// Check each provided cell.
	for (var _o = 0; _o < array_length(_mapping); _o++) {
		var _cx = _mapping[_o][0];
		var _cy = _mapping[_o][1];
		// If the mouse cursor is over this cell, draw the selection box and set the return value to its index.
		if (mouse_is_over(_cx, _cy, _cx + 39, _cy + 39, true)) {
			if (_o < array_length(global.recipe_registry)) {
				_mc = _o;
			}
			draw_roundrect_color(_cx, _cy, _cx + 39, _cy + 39, c_gray, c_gray, false);
		}
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	return _mc;
}	

/**
 * Draw inventory matrix for client side selection.
 *
 * @param {real} _x x-coordinate of top left corner.
 * @param {real} _y y-coordinate of top left corner.
 * @param {struct} _inventory Client-side inventory to draw.
 * @param {real} _rows Number of rows in matrix.
 * @param {bool} _clear Whether to draw the cells or not.
 * @returns {array<array<real>>} Locations of cells.
 */
 // TODO: See if the mouse mapping and drawing methods for these matrices can be merged.
function draw_inventory_matrix(_x, _y, _inventory, _rows, _clear = false) {
	var _cols = ceil(_inventory.slots / _rows)
	var _index = 0;
	var _cm = [];
	// Draw cells in a grid.
	for (var _i = 1; _i <= _rows; _i++) {
		for (var _j = 1; _j <= _cols; _j++ ) {
			if (_index <= _inventory.slots) {
				var _cx = _x + ((_j - 1) * 42);
				var _cy = _y + ((_i - 1) * 42);
				// If this GUI is not transparent, draw the background of the cell.
				if (!_clear) {
					draw_rectangle_color(_cx, _cy, _cx + 39, _cy + 39, c_gray, c_gray, c_gray, c_gray, false);
				}
				// Draw item in this cell, and how much of it there is.
				var _k = _inventory.contents[_index];
				if (_k.stacksize > 0) {
					draw_tile(ts_itemmap, _k.item_id + 1, -1, _cx + 4, _cy + 4)
					if (_k.stacksize > 1) {
						draw_set_halign(fa_right);
						draw_set_valign(fa_bottom);
						draw_text(_cx + 40, _cy + 40, _k.stacksize);
						draw_reset();
					}
				}
				// Store data and increase index.
				var _cmt = [_cx, _cy]
				_cm[_index] = _cmt;
				_index++;
			}
		}
	}
	return _cm;
}
	
/**
 * Determine if mouse is over a slot in the matrix.
 *
 * @param {struct} _inventory Inventory we are over.
 * @param {array} _mapping Coordinates of slots.
 * @returns {real} Slot mouse is over, or -1 if it isn't over any.
 */
function inventory_matrix_mouse_map(_inventory, _mapping) {
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.2);
	var _mc = -1;
	// Check each cell and output which cell has the cursor over it, if any.
	for (var _o = 0; _o < array_length(_mapping); _o++) {
		var _cx = _mapping[_o][0];
		var _cy = _mapping[_o][1];
		if (mouse_is_over(_cx, _cy, _cx + 39, _cy + 39, true)) {
			_mc = _o;
			draw_rectangle_color(_cx, _cy, _cx + 39, _cy + 39, c_white, c_white, c_white, c_white, false);
		}
	}
	// If there is a cell with the cursor over it, set the current invetory selection to it.
	if (_mc != -1 || obj_inputhandler.current_hover[0] == _inventory) {
		obj_inputhandler.current_hover = [_inventory, _mc]
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
}
	
/**
 * Draw sandbox item matrix for client side selection.
 *
 * @param {real} _x x-coordinate of top left corner.
 * @param {real} _y y-coordinate of top left corner.
 * @param {real} _squares Number of squares in matrix.
 * @param {real} _rows Number of rows in matrix.
 * @returns {array<array<real>>} Locations of cells.
 */
function draw_sandbox_item_matrix(_x, _y, _squares, _rows) {
	var _cols = ceil(_squares / _rows);
	var _index = 0;
	var _sim = [];

	// Index through cells and draw avaliable items.
	for (var _i = 1; _i <= _rows; _i++) {
		for (var _j = 1; _j <= _cols; _j++ ) {
			if (_index <= _squares) {
				var _cx = _x + ((_j - 1) * 42);
				var _cy = _y + ((_i - 1) * 42);
				var _col = c_gray;
				draw_rectangle_color(_cx, _cy, _cx + 39, _cy + 39, _col, _col, _col, _col, false);
				if (_index < array_length(global.item_id)) {
					draw_tile(ts_itemmap, _index + 1, -1, _cx + 4, _cy + 4);
				}
				var _cmt = [_cx, _cy]
				_sim[_index] = _cmt;
				_index++;
			}
		}
	}
	return _sim;
}

/**
 * Determine if mouse is over a slot in the matrix.
 *
 * @param {array} _mapping Coordinates of slots.
 * @returns {real} Slot mouse is over, or -1 if it isn't over any.
 */
function sandbox_item_mouse_map(_mapping) {
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.2);
	var _mc = -1;
	// Check if cursor is over a slot.
	for (var _o = 0; _o < array_length(_mapping); _o++) {
		var _cx = _mapping[_o][0];
		var _cy = _mapping[_o][1];
		if (mouse_is_over(_cx, _cy, _cx + 39, _cy + 39, true)) {
			// Only mark this as a valid selection if this cell has an item.
			if (_o < array_length(global.item_id)) {
				_mc = _o;
			}
			draw_rectangle(_cx, _cy, _cx + 39, _cy + 39, false);
		}
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	return _mc;
}	

/**
 * Draw sandbox tile matrix for client side selection.
 *
 * @param {real} _x x-coordinate of top left corner.
 * @param {real} _y y-coordinate of top left corner.
 * @param {real} _squares Number of squares in matrix.
 * @param {real} _rows Number of rows in matrix.
 * @param {asset.GMTileSet} _tileset Tileset ew are using.
 * @returns {array<array<real>>} Locations of cells.
 */
 // TODO: See if the mouse mapping and drawing methods for these matrices can be merged.
function draw_sandbox_tile_matrix(_x, _y, _squares, _rows, _tileset) {
	var _cols = ceil(_squares / _rows);
	var _index = 0;
	var _stm = [];

	// Draw tiles from the currently selected tileset.
	for (var _i = 1; _i <= _rows; _i++) {
		for (var _j = 1; _j <= _cols; _j++ ) {
			if (_index <= _squares) {
				var _cx = _x + ((_j - 1) * 42);
				var _cy = _y + ((_i - 1) * 42);
				var _col = c_gray;
				draw_rectangle_color(_cx, _cy, _cx + 39, _cy + 39, _col, _col, _col, _col, false);
				// Ensure there is a tile to draw.
				if (_index < tileset_get_info(_tileset).tile_count) {
					draw_tile(_tileset, _index, -1, _cx + 4, _cy + 4);
				}
				var _cmt = [_cx, _cy]
				_stm[_index] = _cmt;
				_index++;
			}
		}
	}
	return _stm;
}

/**
 * Determine if mouse is over a slot in the matrix.
 *
 * @param {array} _mapping Coordinates of slots.
 * @param {asset.GMTileSet} _tileset Tileset we are using.
 * @returns {real} Slot mouse is over, or -1 if it isn't over any.
 */
function sandbox_tile_mouse_map(_mapping, _tileset) {
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.2);
	var _mc = -1;
	// Check if cursor is over any of the provided tiles.
	for (var _o = 0; _o < array_length(_mapping); _o++) {
		var _cx = _mapping[_o][0];
		var _cy = _mapping[_o][1];
		if (mouse_is_over(_cx, _cy, _cx + 39, _cy + 39, true)) {
			if (_o < tileset_get_info(_tileset).tile_count) {
				_mc = _o;
			}
			else {
				_mc = 0;
			}
			draw_rectangle(_cx, _cy, _cx + 39, _cy + 39, false);
		}
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	return _mc;
}	
	

/**
 * Draw a simple text box.
 *
 * @param {real} _x x-coordinate of top left corner.
 * @param {real} _y y-coordinate of top left corner.
 * @param {string} _text Text to display.
 */
function draw_text_box(_x, _y, _text, _center = false) {
	// Define textbox dimensions
	var _length = string_width_ext(get_text(_text), -1, 512) + 4;
	var _height = string_height_ext(get_text(_text), -1, 512) + 4;
	
	// Draw textbox
	draw_set_alpha(0.8);
	draw_rectangle_color(_x, _y, _x + _length, _y + _height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	
	// Draw text
	draw_set_halign(_center ? fa_center : fa_left)
	draw_text_ext(_x + 2 + (_center ? _length / 2 : 0), _y + 2, get_text(_text), -1, 512);
	draw_set_halign(fa_left);
}
	
/**
 * Draw info about a recipe.
 *
 * @param {real} _x x-coordinate of top left corner.
 * @param {real} _y y-coordinate of top left corner.
 * @param {struct} _recipe Recipe data to display.
 */
function draw_recipe_info(_x, _y, _recipe) {
	// Generate Header
	var _header = string(_recipe.outputs[0].stacksize) + "x " + get_text(stack_get_item(_recipe.outputs[0]).name);
	
	// Calculate needed width (height is constant for now, may change later)
	var _width = 4 + max(96, string_width(_header), array_length(_recipe.outputs) * 42, array_length(_recipe.inputs) * 42);
	// Draw info
	// Info box
	draw_set_alpha(0.8);
	draw_rectangle_color(_x, _y, _x + _width, _y + 143, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	// Text
	draw_text(_x + 2, _y + 2, _header);
	draw_text(_x + 2, _y + 18, get_text("ui_crafting_requires"));
	draw_text(_x + 2, _y + 80, get_text("ui_crafting_outputs"));
	
	// Icons
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	// Inputs
	for (var _i = 0; _i < array_length(_recipe.inputs); _i++) {
		var _back = make_color_rgb(80, 0, 0);
		// Change background color from red to gray if item is avaliable
		if (inventory_has_items(obj_playerchar.player_inventory, [_recipe.inputs[_i]])) {
			_back = c_dkgray;
		}
		var _dx = _x + 3 + 42 * _i;
		var _id = _recipe.inputs[_i].item_id;
		var _amount = _recipe.inputs[_i].stacksize;
		draw_roundrect_color(_dx, _y + 37, _dx + 39, _y + 77, _back, _back, false);
		draw_tile(ts_itemmap, _id + 1, -1 , _dx + 4, _y + 41);
		draw_text(_dx + 38, _y + 76, _amount);
	}
	// Outputs
	for (var _i = 0; _i < array_length(_recipe.outputs); _i++) {
		var _dx = _x + 3 + 42 * _i;
		var _id = _recipe.outputs[_i].item_id;
		var _amount = _recipe.outputs[_i].stacksize;
		draw_roundrect_color(_dx, _y + 99, _dx + 39, _y + 139, c_dkgray, c_dkgray, false);
		draw_tile(ts_itemmap, _id + 1, -1 , _dx + 4, _y + 103);
		draw_text(_dx + 38, _y + 138, _amount);
	}
	
	// Reset drawing configuration
	draw_reset();
}