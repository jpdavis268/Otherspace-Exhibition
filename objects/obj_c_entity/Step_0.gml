/// @description Depth Sorting and Culling
// Set depth relative to the player character, if it exists.
if (instance_exists(obj_playerchar)) {	
	depth = obj_playerchar.y - y; 
}

// Unload entity if past a certain distance.
if (distance_to_object(obj_playerchar) > 4096) {
	instance_destroy();
}
