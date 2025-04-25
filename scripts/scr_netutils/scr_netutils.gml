/**
 * Converts data into a JSON string and loads it onto a buffer.
 *
 * @param {id.Buffer} _buffer Buffer to use.
 * @param {any} _data Data to load.
 */
function buffer_prepare(_buffer, _data) {
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _tosend = json_stringify(_data);
	buffer_write(_buffer, buffer_text, _tosend);
}
	

/**
 * Compresses an array of numbers for data transmission.
 *
 * @param {array} _array Array to compress.
 * @returns {array<any>} Compressed array.
 */
function num_array_pack(_array) {
	var _out = []; // Output array.
	var _hist = [0, _array[0]]; // Keep track of any chains of numbers as we go.
	var _length = array_length(_array);
	for (var _i = 0; _i < _length; _i++) {
		// If this number is the same as the one stored in histrory, increment the counter.
		if (_array[_i] == _hist[1]) {
			_hist[0]++;
		}
		// Run this if the current number is not the one stored in history, or we hit the end of the array.
		if (_array[_i] != _hist[1] || _i == _length - 1) {
			// If we have more than 4 of the same number in a row, insert a string representing the data.
			if (_hist[0] > 4) {
				array_insert(_out, array_length(_out), "$" + string(_hist[0]) + "|" + string(_hist[1]));
			}
			// Otherwise, just put the numbers in.
			else {
				var _nums = array_create(_hist[0], _hist[1]);
				_out = array_concat(_out, _nums);
			}
			// If we are not at the end of the array or the above condition ran as a result of reaching the end,
			// but there wasn't a break, reset history with the counter at 1.
			if (_i != _length - 1 || _array[_i] == _hist[1]) {
				_hist = [1, _array[_i]];
			}
			// Otherwise, push the last value to the end of the array.
			else {
				array_push(_out, _array[_i]);
			}
		}
	}
	return _out;
}

/**
 * Decompresses a previously compressed numerical array.
 *
 * @param {array<any>} _array Array to decompress.
 * @returns {array<any>} Decompressed array.
 */
function num_array_unpack(_array) {
	var _return = [];
	for (var _i = 0; _i < array_length(_array); _i++) {
		// If we hit one of the info strings, extract the data and add it to the output array.
		if (string_count("$", _array[_i]) > 0) {
			var _ref = string_replace(_array[_i], "$", "");
			var _info = string_split(_ref, "|");
			var _unpack = array_create(real(_info[0]), real(_info[1]));
			_return = array_concat(_return, _unpack);
		}
		// Otherwise, it is a number, so just copy it to the output.
		else {
			array_push(_return, _array[_i]);
		}
	}
	return _return;
}
	
/**
 * Parses JSON data from a buffer.
 *
 * @param {id.Buffer} _buffer Buffer to parse.
 * @return {any*} JSON data from buffer.
 */
function read_data(_buffer) {
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _data = buffer_read(_buffer, buffer_text);
	return json_parse(_data);
}

/**
 * Parse data sent from a server (client-side only).
 *
 * @param {id.Buffer} _buffer Buffer to parse.
 */
function client_parse_data(_buffer) {
	// Increase running total of inbound data.
	obj_gamehandler.network_in += buffer_get_size(_buffer) / 1000;
	
	// Extract data and determine protocol.
	var _data = read_data(_buffer);
	var _pid = _data[0];
	
	// Remove protocol from output data and run  the handler method.
	array_delete(_data, 0, 1);
	client_protocols(_pid, _data);
}
	
/**
 * Parse data sent from a client (server-side only).
 *
 * @param {id.Buffer} _buffer Buffer to parse.
 * @param {id.Socket} _sock Source socket of data.
 */
function server_parse_data(_buffer, _sock) {
	// Extract data and determine protocol.
	var _data = read_data(_buffer);
	var _pid = _data[0];
	
	// Remove protocol from data and run handler method.
	array_delete(_data, 0, 1);
	server_protocols(_pid, _data, _sock);
}

/**
 * Send client data to the server.
 *
 * @param {any} _data Description
 */
function client_send_data(_data) {
	// If we are in singleplayer, just put the data in the "server"'s data buffer.
	if (obj_control.game_type == 0) {
		array_insert(obj_server.client_data, array_length(obj_server.client_data), _data);
	}
	// If not, send it over the network.
	else {
		// Load data onto buffer.
		var _i = buffer_create(1, buffer_grow, 1);
		buffer_prepare(_i, _data);
		
		// Send data over network and add size to running total of outbound data.
		network_send_packet(obj_client.client_socket, _i, buffer_tell(_i));
		obj_gamehandler.network_out += buffer_get_size(_i) / 1000;
		buffer_delete(_i);
	}
}

/**
 * Send server data to a specific client.
 *
 * @param {any} _data Data to send.
 * @param {id.Socket} _socket Socket to send data to.
 */
function server_send_data(_data, _socket) {
	// If we are in singleplayer, just put the data in the client data buffer.
	if (obj_control.game_type == 0) {
		array_insert(obj_client.server_data, array_length(obj_client.server_data), _data);
	}
	// Send data over the network.
	else {
		// Load data onto buffer.
		var _i = buffer_create(1, buffer_grow, 1);
		buffer_prepare(_i, _data);
		
		// Send data to destination socket.
		network_send_packet(_socket, _i, buffer_tell(_i));
		buffer_delete(_i);
	}
}

/**
 * Send data to all connected clients.
 *
 * @param {any} _data Data to send.
 * @param {real} [_excludesocket] Any client to exclude from broadcast (-1 for noone).
 */
function broadcast_data(_data, _excludesocket = -1) {
	// If we are in singleplayer and the "client" is not excluded, put data in client data buffer.
	if (obj_control.game_type == 0) {
		if (_excludesocket == -1) {
			array_insert(obj_client.server_data, array_length(obj_client.server_data), _data);
		}
	}
	// Otherwise, broadcast it over the network.
	else {
		// Load data onto a buffer.
		var _i = buffer_create(1, buffer_grow, 1)
		buffer_prepare(_i, _data);
		// Index through clients, sending all of them the data unless they are specifically excluded.
		for (var _k = 0; _k < ds_list_size(obj_server.socket_list); _k++) {
			var _j = ds_list_find_value(obj_server.socket_list, _k);
			if (_j != _excludesocket) {
				network_send_packet(_j, _i, buffer_tell(_i));
			}
		}
		buffer_delete(_i);
	}
}
	
/**
 * Send data to all clients within a specific range of the calling instance.
 *
 * @param {any} _data Data to send.
 * @param {any*} _range Maximum range to check for players.
 * @param {bool} [_excludecalling] Whether or not to exclude the calling instance, if called by a player object.
 */
function server_send_update(_data, _range, _excludecalling = false) {
	// Get all clients within range.
	var _list = ds_list_create();
	collision_rectangle_list(x - _range, y - _range, x + _range, y + _range, obj_player, false, _excludecalling, _list, false);
	
	// If we are in singleplayer and the player is in the above list, put the data in the client data buffer.
	if (obj_control.game_type == 0) {
		if (ds_list_size(_list) > 0) {
			array_insert(obj_client.server_data, array_length(obj_client.server_data), _data);
		}
	}
	// Otherwise, send it over the network to the discovered players.
	else {
		for (var _k = 0; _k < ds_list_size(_list); _k++) {
			var _j = ds_list_find_value(_list, _k);
			server_send_data(_data, _j.my_client);
		}
		ds_list_destroy(_list);
	}
}
	

/**
 * Add player to the server.
 *
 * @param {string} _username Player username.
 * @param {real} _datakey Playerdata key.
 * @param {id.Socket} _socket Client socket of player.
 */
function network_player_join(_username, _datakey, _socket) {
	// Check if another player with the same username is already connected.
	if (ds_map_exists(obj_server.username_mapping, _username)) {
		_username = _username + "_";
	}

	// Create a player instance
	var _player = instance_create_layer(irandom(64), irandom(64), "Server", obj_player);
	_player.username = _username;
	_player.my_client = _socket;
	
	// If player has data, load it into the new player object.
	// Player info
	var _playerdata = global.current_save + "/playerdata/" + string(_datakey);
	if (directory_exists(_playerdata)) {
		// General Data
		var _datafile = _playerdata + "/playerdata.json";
		if (file_exists(_datafile)) {
			// Load data
			var _gendata = load_json(_datafile);
			_player.x = _gendata.x;
			_player.y = _gendata.y;
			_player.game_mode = _gendata.gm;
		}
		
		// Inventory
		var _invfile = _playerdata + "/inventory.dat";
		if (file_exists(_invfile)) {
			// Load inventory data.
			var _invdata = buffer_load(_invfile);
			_invdata = buffer_decompress(_invdata);
			var _inventory = read_data(_invdata);
			
			// Give new player object inventory data.
			_player.player_inventory.contents = _inventory.main;
			_player.held_item.contents = _inventory.held;
		}
	}
		
	// Add player to mappings.
	ds_map_add(obj_server.player_mapping, _socket, _player);
	ds_map_add(obj_server.username_mapping, _username, _player);
	ds_map_add(obj_server.interface_mapping, _socket, noone);
	ds_map_add(obj_server.playerdata_mapping, _player, _datakey);
	
	// Send information to joining client.
	server_send_data([1, _player.x, _player.y, _player.username, string(_player.id), _player.game_mode], _socket);
	sync_call(false, _socket);
	
	// Establish constant interface with player client.
	method_call(_player.interface_establish_info, [_socket]);
	
	// Join Message
	if (obj_control.game_type != 0) {
		broadcast_data([2, _username + " has joined the game"]);
		console_log(0, _username + " joined.");
	}
}
	
/**
 * Check if data received from a client is valid.
 *
 * @param {array} _data Data to check.
 * @param {array} _expectedvalues What we expect the data to be.
 * @returns {bool} Whether the data was as expected.
 */
function data_array_is_valid(_data, _expectedvalues) {
	var _isbad = false;
	// Check array length.
	if (array_length(_data) != array_length(_expectedvalues)) {
		_isbad = true;
	}
	// Check data types.
	for (var _i = 0; _i < array_length(_data) && !_isbad; _i++) {
		if (typeof(_data[_i]) != _expectedvalues[_i]) {
			_isbad = true;
		}
	}
	// If the data is bad, print warning message and return false.
	if (_isbad) {
		console_log(1, "Invalid network data array! This is likely a result of a bug or tampering.");
		return false;
	}
	return true;
}
	
/**
 * Log server message to the GMS console. Type 0 is a message, 1 is a warn, and 2 is an error.
 *
 * @param {real} _type Type of message.
 * @param {string} _message Message to send/
 */
function console_log(_type, _message) {
	var _prefix;
	switch (_type) {
		case 0: {_prefix = "[MESSAGE] "} break;
		case 1: {_prefix = "[WARN] "} break;
		case 2: {_prefix = "[ERROR] "} break;
	}
	// This should eventually print to a log file as well.
	show_debug_message(_prefix + _message);
}
	
/**
 * Send an entity update.
 *
 * @param {real} _protocol Client protocol to mark data with.
 * @param {array} _data Data to send.
 */
function entity_send_update(_protocol, _data) {
	// Get id and prepare data header.
	var _id = string(self.id);
	var _tosend = [9, _id, _protocol];
	
	// Append data to header and send to nearby clients.
	array_copy(_tosend, 3, _data, 0, array_length(_data));
	server_send_update(_tosend, 4608)
}

/**
 * Send establishing info when a client loads an entity.
 *
 * @param {real} _protocol Client protocol to use.
 * @param {array} _data Data to send.
 * @param {id.Socket} _socket Socket to send data to.
 */
function entity_establish_info(_protocol, _data, _socket) {
	// Prepare data header.
	var _id = string(self.id);
	var _tosend = [9, _id, _protocol];
	
	// Append data to header and send it to socket.
	array_copy(_tosend, 3, _data, 0, array_length(_data));
	server_send_data(_tosend, _socket);
}
	

/**
 * Send an entity update to clients on an entity's interface list.
 *
 * @param {real} _protocol Client protocol to use.
 * @param {array} _data Data to send.
 */
function entity_send_interface_update(_protocol, _data) {
	// Prepare data header.
	var _id = string(self.id);
	var _tosend = [9, _id, _protocol];
	
	// Append data to header.
	array_copy(_tosend, 3, _data, 0, array_length(_data));
	var _sendto = [];
	
	// If we are in singleplayer, set the destination socket to 0.
	if (obj_control.game_type = 0) {
		_sendto = [0];
	}
	// Otherwise, if we are a player, set the destination socket to our client.
	else if (self.object_index = obj_player) {
		_sendto = [self.my_client];
	}
	// Otherwise, add any socket that is currently interfacing with us to the list.
	else {
		// Checking this every time an interface update is called is probably a bad idea, 
		// but I doubt any server will ever have enough players for this to start causing problems, so it will work for now.
		for (var _i = 0; _i < ds_list_size(obj_server.socket_list); _i++) {
			var _sock = ds_list_find_value(obj_server.socket_list, _i);
			if (ds_map_exists(obj_server.interface_mapping, _sock) && ds_map_find_value(obj_server.interface_mapping, _sock) == self.id) {
				array_insert(_sendto, array_length(_sendto), _sock);
			}
		}
	}
	// Send data to everyone interfacing with us.
	for (var _i = 0; _i < array_length(_sendto); _i++) {
		server_send_data(_tosend, _sendto[_i]);
	}
}
	

/**
 * Handle player leaving or being kicked from the server.
 *
 * @param {id.Socket} _socket Socket of player who left.
 */
function network_player_leave(_socket) {	
	// Find player leaving.
	var _i = ds_list_find_index(obj_server.socket_list, _socket);
	// If they can't be found, exit.
	if (_i == -1) {
		exit;
	}
	
	// Remove socket from list.
	ds_list_delete(obj_server.socket_list, _i);
	
	// If they are on the operators list, remove them (need to have a permanant record of operators eventually).
	var _j = ds_list_find_index(obj_server.operators, _socket);
	if (_j != -1) {
		ds_list_delete(obj_server.operators, _j);
	}
	
	// Find player attached to socket.
	var _player = ds_map_find_value(obj_server.player_mapping, _socket);
	var _username = _player.username;
	
	// Save the player's data and remove their instance from the game.
	save_player_data(_player);
	instance_destroy(_player);
	
	// Remove this player from all mappings.
	ds_map_delete(obj_server.player_mapping, _socket);
	ds_map_delete(obj_server.username_mapping, _username);
	ds_map_delete(obj_server.interface_mapping, _socket);
	ds_map_delete(obj_server.playerdata_mapping, _player);
	
	// Broadcast that the player has left.
	broadcast_data([2, string(_username) + " has left the game"], 1);
	console_log(0, _username + " left.");
}

/**
 * Fetch the player datakey for a server a client joins, and create it if it doesn't exist.
 *
 * @param {string} _serverid Id of server.
 * @returns {real} Client datakey.
 */
function client_fetch_playerkey(_serverid) {
	// Open player data file.
	ini_open("datakeys.ini");
	
	if (ini_key_exists("Data", _serverid)) {
		// If player key exists, return it.
		var _id = ini_read_real("Data", _serverid, -1);
		ini_close();
		return _id;
	}
	else {
		// Otherwise, create it and then return it.
		var _timestamp = int64(date_second_span(date_current_datetime(), date_create_datetime(2024, 12, 31, 23, 59, 59))) % 999999999999;
		var _id = string(_timestamp) + string(irandom(999999));
		
		ini_write_string("Data", _serverid, _id);
		ini_close();
		return real(_id);
	}
}


/**
 * Send a synchronization call to a client or all clients.
 *
 * @param {bool} [_global] Whether to send it to every client.
 * @param {id.Socket, real} [_target] Socket to send data to, if applicable.
 */
function sync_call(_global = false, _target = -1) {
	// Prepare data.
	var _data = [4, obj_manager.sec, obj_manager.tick, fps];
	
	// Send the call to everyone or the target, depending on whether it is global or not.
	if (_global) {
		broadcast_data(_data);
	}
	else {
		server_send_data(_data, _target);
	}
}