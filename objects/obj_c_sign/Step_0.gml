/// @description Show text when hovered over.
if (collision_point(obj_selector.x, obj_selector.y, self, false, false) && !global.paused && obj_guihandler.current_gui == noone) {
	global.hover_text = my_text;
	global.hover_center = true;
}

// Update data if not in use.
if (obj_guihandler.current_gui == noone) {
	input_position = string_length(cached_text);
	input_position_offset = 0;
	line = 0;
	
	if (cached_text != my_text) {
		my_text = cached_text;
		
		// Update Server
		client_send_data([4, 10, [server_id, my_text]]);
	}
}