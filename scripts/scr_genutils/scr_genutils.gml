/**
 * Draw a light source on the lighting layer.
 *
 * @param {real} _x x-coordinate of light source.
 * @param {real} _y y-coordinate of light source.
 * @param {real} _scale Size of light.
 * @param {constant.Color} _color Color of light.
 * @param {real} _alpha Strength of light from 0 to 1.
 */
function draw_light(_x, _y, _scale, _color, _alpha) {
	with (obj_lighthandler) {
		// If the lighting surface exists, subtract the light sprite from it.
		// Need to find a better solution for this, right now it just draws a scaled giant dot.
		if (surface_exists(light_surface)) {
			surface_set_target(light_surface);
			gpu_set_blendmode(bm_subtract);
			draw_sprite_ext(spr_light, -1, _x - camera_get_view_x(view_camera[0]), _y - camera_get_view_y(view_camera[0]), _scale, _scale, 0, _color, _alpha);
			gpu_set_blendmode(bm_normal);
			surface_reset_target();
		}
	}
}
	
	
/**
 * Reload graphics settings.
 */
function load_graphics_settings() {
	var _o = global.settings;
	window_set_fullscreen(_o.fullscreen);
}


/**
 * Get the names of all saved worlds.
 *
 * @returns {array<string>} List of saves.
 */
function get_saves() {
	var _saves = [];
	var _nextsave = file_find_first("saves/*", fa_directory);
	while (_nextsave != "") {
		// Only add file to list if (presumably) valid save.
		// If somone throws a random file in the saves folder with a fake manifest, they're on their own.
		if (file_exists("saves/" + _nextsave + "/manifest.json")) {
			array_push(_saves, _nextsave);
		}
		_nextsave = file_find_next();
	}
	file_find_close();
	
	return _saves;
}

/**
 * Retreive info about a list of save folders from their mainfest.json file.
 *
 * @param {array<string>} _saves List of saves.
 * @returns {array<struct>} Save manifest data.
 */
function retrieve_save_manifests(_saves) {
	// Index through save list and get the manifest of each.
	var _save_info = [];
	for (var _i = 0; _i < array_length(_saves); _i++) {
		_save_info[_i] = load_json("saves/" + _saves[_i] + "/manifest.json");
	}
	
	return _save_info;
}


/**
 * Retreive text from current lang map using a key.
 *
 * @param {string} _key Key of text on lang map.
 * @return {string} Text at key, or the key itself if the text could not be found.
 */
function get_text(_key) {
	/// Running this every frame probably isn't very efficient, but (hopefully) there will never be enough
	/// text on screen for this to be an issue, and trying to set up some preloaded thing would make this drastically
	/// more complicated.
	var _text = struct_get(global.text_map, _key);
	if (is_undefined(_text)) {
		return _key;
	}
	return _text;
}


/**
 * Check if mouse is over an area.
 *
 * @param {real} _x1 Left x-coordinate to check.
 * @param {real} _y1 Top y-coordinate to check.
 * @param {real} _x2 Right x-coordinate to check.
 * @param {real} _y2 Bottom y-coordinate to check.
 * @param {bool} [_gui] Whether to check the gui layer or game world.
 * @param {bool} [_guiman_override] Whether we want to override obj_guimanager, even if it would normally be in use.
 * @returns {bool} Whether the mouse was over the area.
 */
function mouse_is_over(_x1, _y1, _x2, _y2, _gui = false, _guiman_override = false) {
	// Determine which mouse coordinates to use.
	var _override = !obj_control.initialized || obj_guihandler.current_gui == noone || _guiman_override;
	var _mx = _gui ? (_override ? window_mouse_get_x() : obj_guihandler.gui_mouse_x) : mouse_x;
	var _my = _gui ? (_override ? window_mouse_get_y() : obj_guihandler.gui_mouse_y) : mouse_y;
	
	return is_in_range(_mx, _x1, _x2) && is_in_range(_my, _y1, _y2);
}
	
/**
 * Retreive item data for an itemstack.	
 *
 * @param {any*} _itemstack Itemstack to check.
 * @returns {struct} Item data.
 */
function stack_get_item(_itemstack) {
	return global.item_id[_itemstack.item_id];
}