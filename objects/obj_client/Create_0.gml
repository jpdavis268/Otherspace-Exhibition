/// @description Attempt to Connect to Server
if (obj_control.game_type == 0) {
	// Singleplayer
	server_data = []; // "Server" data buffer
	var _key = client_fetch_playerkey(obj_server.save_id); // Player data key.
	client_send_data([0, global.settings.username, _key]);
}
else {
	// Connect to Server
	client_socket = network_create_socket(network_socket_tcp); // Network Socket
	if (obj_control.game_type == 3) {
		// We are connecting to another server.
		server = network_connect(client_socket, global.connect_to, 26284); // Connect to host.
	}
	else {
		// We are hosting a server.
		server = network_connect(client_socket, "127.0.0.1", 26284); // Connect to loopback IP.
	}
	// Return to menu if server does not exist.
	if (server < 0) {
		room_goto(rm_menu);
	}
}

// Client Ping Call
global.pingcall = call_later(1, time_source_units_seconds, function () {
	// Prevents rogue call from crashing game after exiting.
	if (obj_control.initialized && instance_exists(obj_client) && instance_exists(obj_gamehandler) && !(global.paused && obj_control.game_type == 0)) {
		client_send_data([2, current_time]);
	}
	else if (!obj_control.initialized){
		call_cancel(global.pingcall);
	}
}, true);