/// @description Create Server
player_mapping = ds_map_create(); // Mapping of players to sockets.
username_mapping = ds_map_create(); // Mapping of players and usernames.
interface_mapping = ds_map_create(); // Mapping of players to entity interfaces.
playerdata_mapping = ds_map_create(); // Mapping of players to playerdata.
operators = ds_list_create(); // List of players with operator permissions
network_tracker = []; // Track client data input amounts (to detect DDoS attempts)
alarm[0] = 60; // Network tracking reset timer.

// Get save id
var _idfile = file_text_open_read(global.current_save + "/saveid");
save_id = file_text_read_real(_idfile);
file_text_close(_idfile);

// If in singleplayer, set up client data buffer and add player to operator list.
if (obj_control.game_type == 0) {
	client_data = [];
	ds_list_add(operators, -1);
}
// Otherwise, create server and socket list and add host to operator list if applicable.
else {
	server_socket = network_create_server(network_socket_tcp, 26284, 5);
	socket_list = ds_list_create();
	if (obj_control.game_type == 1) {
		// Add host client to operator list (host client socket will always be 2).
		ds_list_add(operators, 2);
	}
}

// Dedicated Server Menu
if (obj_control.game_type == 2) {
	show_debug_log(true);
}
	
// Synchronization Call
global.synccall = call_later(1, time_source_units_seconds, function () {
	// Prevents rogue call from crashing game after exiting.
	if (obj_control.initialized && instance_exists(obj_manager) && !(obj_control.game_type == 0 && global.paused)) {
		sync_call(true);
	}
	else if (!obj_control.initialized) {
		call_cancel(global.synccall);
	}
}, true);