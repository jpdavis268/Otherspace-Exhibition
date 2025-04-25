// Valid Console Commands
global.console_commands = [
	"op",
	"deop",
	"kick",
	"broadcast",
	"give",
	"timeset",
	"tp",
	"gamemode",
	"setdefaultgamemode"
];

/**
 * Add a user to the operator list.
 *
 * @param {string} _username User to add.
 * @returns {string} Command Feedback
 */
function op(_username) {
	// Does player with username exist?
	if (ds_map_find_value(obj_server.username_mapping, _username) == undefined) {
		return "Unable to find player with username " + _username;
	}
	
	// Get socket associated with username.
	var _inst = ds_map_find_value(obj_server.username_mapping, _username);
	var _sock = _inst.my_client;
	
	// Is player already opped?
	if (ds_list_find_index(obj_server.operators, _sock) != -1) {
		return _username + " is already opped.";
	}
	
	// Add player to operator list if previous conditions are not met.
	ds_list_add(obj_server.operators, _sock);
	return "Added " + _username + " to operator list.";
}

/**
 * Remove a user to the operator list.
 *
 * @param {string} _username User to remove.
 * @returns {string} Command Feedback
 */
function deop(_username) {
	// Does player with username exist?
	if (ds_map_find_value(obj_server.username_mapping, _username) == undefined) {
		return "Unable to find player with username " + _username;
	}
	
	// Get socket associated with username.
	var _inst = ds_map_find_value(obj_server.username_mapping, _username);
	var _sock = _inst.my_client;
	
	// Is player opped?
	if (ds_list_find_index(obj_server.operators, _sock) == -1) {
		return _username + " is not opped.";
	}
	
	// Remove player to operator list if previous conditions are not met.
	var _i = ds_list_find_index(obj_server.operators, _sock);
	ds_list_delete(obj_server.operators, _i);
	return "Removed " + _username + " from operator list.";
}

/**
 * Kick a player from the server.
 *
 * @param {string} _username User to kick.
 * @returns {string} Command Feedback
 */
function kick(_username) {
	// Does player with username exist?
	if (ds_map_find_value(obj_server.username_mapping, _username) == undefined) {
		return "Unable to find player with username " + _username;
	}
	
	// Get socket associated with username.
	var _inst = ds_map_find_value(obj_server.username_mapping, _username);
	var _sock = _inst.my_client;
	
	// Catch: Prevent player from kicking the host
	if (obj_control.game_type == 1 && _sock == 2) {
		return "Cannot kick server host."
	}
	
	// Kick Player
	// network_destroy is broken in this GMS build. It should function in the next version, but for now the best
	// that can be done to forcibly disconnect a client is to remove them from the list and pretend they don't exist.
	network_player_leave(_sock);
	return "Kicked " + _username + " from the server."
}
	
/**
 * Print a server message in chat for all clients.
 *
 * @param {string} _message Message to broadcast.
 */
function broadcast(_message) {
	var _send = "[!] " + _message;
	broadcast_data([2, _send]);
	show_debug_message(_send);
}
	
/**
 * Give a player x of an item.
 *
 * @param {string} _username Description
 * @param {string} _itemid Description
 * @param {string} _amount Description
 * @returns {string} Command Feedback
 */
function give(_username, _itemid, _amount) {
	// Does player with username exist?
	if (ds_map_find_value(obj_server.username_mapping, _username) == undefined) {
		return "Unable to find player with username " + _username;
	}
	
	// Get player instance associated with username.
	var _inst = ds_map_find_value(obj_server.username_mapping, _username);
	
	// Make sure item id and amount are numbers.
	try {
		var _t1 = real(_itemid);
		_t1 = real(_amount);		
	}
	catch(_exception) {
		return "Syntax Error";
	}
	
	// Ensure item id is a real item.
	if (array_length(global.item_id) <= _itemid ) {
		return "Item does not exist!";
	}
	
	// Limit maximum items given to 256 for stability reasons, may increase later.
	if (_amount > 256) {
		return "Cannot give more than 256 of an item!";
	}
	
	// Give player requested items.
	with (_inst) {
		inventory_add(_inst.player_inventory, new ItemStack(real(_itemid), real(_amount)), 1);
	}
	return "Gave " + _username + " " + string(_amount) + " of " + get_text(global.item_id[_itemid].name);
}
	

/**
 * Set the time to a value.
 *
 * @param {string} _value New time (in seconds from midnight on day 1).
 * @returns {string} Command Feedback
 */
function timeset(_value) {
	var _sec = string_digits(_value);
	
	if (_sec = "") {
		return "Syntax Error";
	}

	obj_manager.sec = real(_value);
	return "Set time to " + _sec + " seconds.";
}

/**
 * Teleport a player to a specific location.
 *
 * @param {string} _username Player to teleport.
 * @param {string, real} [_x] x-coordinate to teleport to.
 * @param {string, real} [_y] y-coordinate to teleport to.
 * @returns {string} Command Feedback
 */
function tp(_username, _x = 0, _y = 0) {
	// Does player with username exist?
	if (ds_map_find_value(obj_server.username_mapping, _username) == undefined) {
		return "Unable to find player with username " + _username;
	}
	
	// Get player instance associated with username.
	var _inst = ds_map_find_value(obj_server.username_mapping, _username);
	
	// Confirm coordinates are valid numbers.
	try {
		var _t1 = real(_x);
		_t1 = real(_y);
	}
	catch(_exception) {
		return "Invalid coordinates!";
	}
		
	// Are coordinates within world limit?
	if (_x > 100000 || _y > 100000) {
		return "Outside of world. Maximum teleporation distance is 100000 on any axis.";
	}	
	
	// Teleport player to location.
	with (_inst) {
		x = real(_x) * 32;
		y = real(_y) * 32;
		
		// For some reason the player object don't fire these on their own, so they must be executed manually here.
		server_send_data([10, x, y], my_client);
		server_send_update([8, ds_map_find_value(obj_manager.entity_mapping, string(id)), x, y], 4608, true);
	}
	return "Teleported " + _username + " to x: " + string(_x) + ", y: " + string(_y);
}

/**
 * Set the gamemode of a specific player.
 *
 * @param {string} _username Player to set gamemode of.
 * @param {string} _gamemode Gamemode to set player to.
 * @returns {string} Command Feedback
 */
function gamemode(_username, _gamemode) {
	// Does player with username exist?
	if (ds_map_find_value(obj_server.username_mapping, _username) == undefined) {
		return "Unable to find player with username " + _username;
	}
	
	// Get player instance associated with username.
	var _inst = ds_map_find_value(obj_server.username_mapping, _username);
	
	// Get gamemode value
	var _gm = string_digits(_gamemode);
	
	// Ensure a number was parsed.
	if (_gm == "") {
		return "Invalid Gamemode!";
	}
	
	// Clamp gamemode input
	var _r = clamp(real(_gm), 0, 1);
	
	// Set gamemode
	_inst.game_mode = _r;
	server_send_data([12, _r], _inst.my_client);
	return string("Set {0}'s gamemode to {1}", _username, _r ? "Sandbox" : "Survival");
}

/**
 * Set the default gamemode for the server.
 *
 * @param {string} _gamemode Gamemode to set as default.
 * @returns {string} Command Feedback
 */
function setdefaultgamemode(_gamemode) {
	// Get gamemode value
	var _gm = string_digits(_gamemode);
	
	// Ensure a number was parsed.
	if (_gm == "") {
		return "Invalid Gamemode!";
	}
	
	// Clamp gamemode input
	var _r = clamp(real(_gm), 0, 1);
	
	// Set default gamemode
	global.default_gm = _r;
	return string("Set default gamemode to {0}", _r ? "Sandbox" : "Survival");
}