/// @description Singleplayer Data Handling
// If not in singleplayer, exit.
if (obj_control.game_type != 0) {
	exit;
}
	
// If there is data in the buffer, process it.
if (array_length(client_data) > 0) {
	for (var _i = 0; _i < array_length(client_data); _i++) {
		var _data = client_data[_i];
		var _pid = _data[0];
		array_delete(_data, 0, 1);
		server_protocols(_pid, _data, -1)
	}
	client_data = [];
}