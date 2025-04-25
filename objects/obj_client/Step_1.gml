/// @description Singleplayer Data Handling
if (obj_control.game_type != 0) {
	// If we are not in singleplayer, exit.
	exit;
}

if (array_length(server_data) > 0) {
	// If the "server" data buffer has data, process it.
	for (var _i = 0; _i < array_length(server_data); _i++) {
		var _data = server_data[_i];
		var _pid = _data[0];
		array_delete(_data, 0, 1);
		client_protocols(_pid, _data);
	}
	server_data = [];
}