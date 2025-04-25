/// @description Entity Movement
// Move Entity
// Get nearby chunks.
var _cl = [];

for (var _i = 0; _i < 3; _i++) {
	for (var _j = 0; _j < 3; _j++) {
		var _tx = (floor(x / 512) * 512) - 512 + (512 * _i);
		var _ty = (floor(y / 512) * 512) - 512 + (512 * _j);
		if chunk_exists_at(_tx, _ty) {
			array_insert(_cl, array_length(_cl), variable_instance_get(get_chunk(_tx, _ty), "stm"));				
		}	
	}
}

// Temporary code for determining movement speed. This obviously won't scale, need to tie it to the tiles themselves.
var _curchunk = get_chunk(x, y);
if (_curchunk != noone) {
	// If this is a player in sandbox mode, give it increased speed and ignore water.
	if (object_index == obj_player && game_mode) {
		move_speed = 9;
	}
	// Otherwise, handle it normally.
	else {
		switch (tilemap_get_at_pixel(_curchunk.gtm, x, y)) {
			case 3: move_speed = 2; break; // Shallow Water
			case 4: move_speed = 1; break; // Deep Water
			default: move_speed = 3; 
		}
	}
}

// Seeing that the only thing to worry about with collisions right now is tileentities, I am going check for the tileentity parent. This will likely have to be changed later.
// Round move speed and move by 1 pixel that many times (not ideal, but prevents weird interactions with walls. Will revisit later).
repeat (round(move_speed)) {
	// Check that we are moving into a valid chunk, and are not about to collide with something (ignore if player in sandbox mode).
	if (chunk_exists_at((x + vx), y) && (!place_meeting(x + vx, y, _cl) && !place_meeting(x + vx, y, obj_par_tileentity)) || (object_index == obj_player && game_mode)) {
		x += vx; 
	}

	if (chunk_exists_at(x, (y + vy)) && (!place_meeting(x, y + vy, _cl) && !place_meeting(x, y + vy, obj_par_tileentity)) || (object_index == obj_player && game_mode)) {
		y += vy;
	}
}
	
// If we moved, tell nearby clients.
if (x != xprevious || y != yprevious) {
	server_send_update([8, ds_map_find_value(obj_manager.entity_mapping, string(id)), x, y], 4608, true);
	}