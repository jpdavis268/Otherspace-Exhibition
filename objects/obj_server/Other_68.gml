/// @description Server Data Handling
var _event = ds_map_find_value(async_load, "type");
var _id = ds_map_find_value(async_load, "id");

switch (_event) {
	case network_type_connect: { // Player Connected
		// Add client to socket list, send save id, and request player info.
		var _socket = ds_map_find_value(async_load, "socket");
		ds_list_add(socket_list, _socket);
		server_send_data([0, save_id], _socket);
	} break;
	case network_type_disconnect: { // Player Left
		// Handle player disconnection.
		var _socket = ds_map_find_value(async_load, "socket");
		network_player_leave(_socket);
	} break;
	case network_type_data: { // Client Data
		// Make sure data is not from own client if we are both hosting and playing.
		if (_id - 1 != server_socket || obj_control.game_type == 2) {
			// Extract packet data
			var _buffer = ds_map_find_value(async_load, "buffer");
			
			// Increase this clients network input on tracker.
			var _log = ds_list_find_index(socket_list, _id);
			if (_log < array_length(network_tracker)) {
				network_tracker[_log] += buffer_get_size(_buffer);
			}
			else {
				network_tracker[_log] = buffer_get_size(_buffer);
			}
			// If client has sent over 10 KB in the last second, kick them from the server.
			if (network_tracker[_log] > 10000) {
				console_log(1, "Socket client data exceeded 10 KB/s! Barring bugs, this may be a DDoS attempt!");
				// This should kick the player as well, was not implemented initially due to the method being broken at the time.
				exit;
			}
			
			// Process the data extracted from the packet.
			server_parse_data(_buffer, _id);
		}
	} break;
}