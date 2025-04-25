/**
 * Check if a chunk exists at a location (serverside).
 *
 * @param {real} _x x-coordinate to check.
 * @param {real} _y y-coordinate to check.
 * @returns {bool} Whether chunk exists.
 */
function chunk_exists_at(_x, _y) {
	// Get chunk coordinates.
	var _cx = floor(_x / 512) * 512;
	var _cy = floor(_y / 512) * 512;
	
	return bool(instance_position(_cx, _cy, obj_chunk));
}

/**
 * Check if a chunk exists at a location (clientside).
 *
 * @param {real} _x x-coordinate to check.
 * @param {real} _y y-coordinate to check.
 * @returns {bool} Whether chunk exists.
 */
function client_chunk_exists_at(_x, _y) {
	// Get chunk coordinates.
	var _cx = floor(_x / 512) * 512;
	var _cy = floor(_y / 512) * 512;
	
	return bool(instance_position(_cx, _cy, obj_c_chunk));
}

/**
 * Get chunk at a location.
 *
 * @param {real} _x x-coordinate to check.
 * @param {real} _y y-coordinate to check.
 * @returns {Id.Instance} Chunk at position (returns noone if none exists).
 */
function get_chunk(_x, _y) {
	var _cx = floor(_x / 512) * 512;
	var _cy = floor(_y / 512) * 512;
	return instance_position(_cx, _cy, obj_chunk);
}
	
/**
 * Get client chunk at a location.
 *
 * @param {real} _x x-coordinate to check.
 * @param {real} _y y-coordinate to check.
 * @returns {Id.Instance} Chunk at position (returns noone if none exists).
 */
function client_get_chunk(_x, _y) {
	var _cx = floor(_x / 512) * 512;
	var _cy = floor(_y / 512) * 512;
	return instance_position(_cx, _cy, obj_c_chunk);
}
	
/**
 * Convert chunk tiledata to an array.
 *
 * @param {id.TileMapElement} _tilemap Tilemap to convert.
 * @returns {array<real>} Output array.
 */
function chunk_tm_to_array(_tilemap) {
	var _d = array_create(256);
	var _i = 0;
	// Loop through chunk tilemap.
	for (var _y = 0; _y < 16; _y++) {
		for (var _x = 0; _x < 16; _x++) {
			// Get tiledata from this cell and add it to the array.
			var _h = tilemap_get(_tilemap, _x, _y)
			_d[_i] = _h;
			_i++;
		}
	}
	return _d;
}

/**
 * Convert chunk tiledata to an array.
 *
 * @param {array<real>} _array Array to convert.
 * @param {id.TileMapElement} _tilemap Tilemap to put data on.
 */
function array_to_chunk_tm(_array, _tilemap) {
	var _i = 0;
	var _length = array_length(_array);
	for (var _y = 0; _y < 16; _y++) {
		for (var _x = 0; _x < 16 && _i < _length; _x++) {
			// Get data from array and add it to tilemap at coordinates.
			tilemap_set(_tilemap, _array[_i], _x, _y);
			_i++;
		}
	}
}

/**
 * Send a chunk update to clients near a chunk.
 *
 * @param {array} _args Information to send.
 */
function send_chunk_update(_args) {
	// 0 - x-coordinate
	// 1 - y-coordinate
	// 2 - Layer
	// 3 - Tiledata
	server_send_update([11,  _args[0], _args[1], _args[2], _args[3]], 4608);
}