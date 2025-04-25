/**
 * Process data sent to server.
 *
 * @param {real} _protocol Protocol of data (what it is suppoed to be).
 * @param {array} _data Data to process.
 * @param {id.Socket} _sock Source socket of data.
 */
function server_protocols(_protocol, _data, _sock) {
	switch (_protocol) {
		 // 0 - Server Client Establishment
		case 0: {
			if (!data_array_is_valid(_data, ["string", "number"])) {
				exit;
			}
			
			// Execute joining function with client username and socket.
			var _username = _data[0];
			var _datakey = _data[1];
			network_player_join(_username, _datakey, _sock);
		} break;
				
		// 1 - Chat Message Sent
		case 1: {
			if (!data_array_is_valid(_data, ["string"])) {
				exit;
			}
			
			// Get client username and send message to all clients with it attached.
			var _player = ds_map_find_value(obj_server.player_mapping, _sock);
			if (variable_instance_exists(_player, "username")) {
				var _message = _player.username + ": " + _data[0];
				broadcast_data([2, _message]);
				console_log(0, _message);
			}
		} break;
			
		// 2 - Client Latency Check
		case 2: {
			if (!data_array_is_valid(_data, ["number"])) {
				exit;
			}
			
			// Send "pong" to client.
			server_send_data([3, _data[0]], _sock);
		} break;
			
		// 3 - Client Requests Chunk Data
		case 3: {
			if (!data_array_is_valid(_data, ["number", "number"])) {
				exit;
			}
			
			// Get chunk at requested location.
			var _x = _data[0];
			var _y = _data[1];
			var _c = get_chunk(_x, _y);
		
			// Pack chunk data and send to client.
			if (_c != noone) {
				// Convert chunk tilemaps to arrays.
				var _gtm = chunk_tm_to_array(_c.gtm);
				var _ftm = chunk_tm_to_array(_c.ftm);
				var _stm = chunk_tm_to_array(_c.stm);
				// Compess arrays for transfer and send to client.
				_gtm = num_array_pack(_gtm);
				_ftm = num_array_pack(_ftm);
				_stm = num_array_pack(_stm);
				server_send_data([5, _x, _y, _gtm, _ftm, _stm], _sock);
			}
		} break;
			
		// 4 - Client Input
		case 4: {
			if (!data_array_is_valid(_data, ["number", "array"])) {
				exit;
			}
			
			// Find player and extract input.
			var _player = ds_map_find_value(obj_server.player_mapping, _sock);
			var _input = [_data[0], _data[1]];		
			
			// If the player exists, put the input data into their buffer.
			if (instance_exists(_player)) {
				array_insert(_player.client_input, array_length(_player.client_input), _input);
			}
		} break;
			
		// 5 - Client Interface Change
		case 5: {
			if (!data_array_is_valid(_data, ["string"])) {
				exit;
			}
			
			// If this is a cancel order, set the socket interface to null.
			if (_data[0] == "cancel") {
				ds_map_replace(obj_server.interface_mapping, _sock, noone);
			}
			// Otherwise, get target and set socket interface to it, then call the establishing info method.
			else {
				var _target = ds_map_find_value(obj_manager.entity_mapping, _data[0]);
				if (_target != undefined) {
					ds_map_replace(obj_server.interface_mapping, _sock, _target);
					method_call(_target.interface_establish_info, [_sock]);
				}
			}
		} break;
			
		// 6 - Console Command
		case 6: {
			if (!data_array_is_valid(_data, ["string"])) {
				exit;
			}
			
			// Check that this player is an operator.
			if (ds_list_find_index(obj_server.operators, _sock) == -1) {
				server_send_data([2, "You do not have permission to use that command."], _sock);
				exit;
			}
			
			// If they are, process the command.
			process_console_command(_data[0], _sock);
		} break;
	}
}
	
/**
 * Process data sent to client from server.
 *
 * @param {real} _protocol Data protocol to use.
 * @param {array} _data Data from server.
 */
function client_protocols(_protocol, _data) {
	switch (_protocol) {
		// 0 - Client Establishment
		case 0: {
			// Send requested username and data key to server.
			var _key = client_fetch_playerkey(_data[0]);
			client_send_data([0, global.settings.username, _key]);
		} break;
			
		// 1 - Initialize Player Object
		case 1: {
			// Get position and updated username from packet.
			var _x = _data[0];
			var _y = _data[1];
			var _username = _data[2];
			var _gm = _data[4];
		
			// Create and initialize own player.
			obj_gamehandler.player_username = _username;
			var _a = instance_create_layer(_x, _y, "Instances", obj_playerchar);
			ds_map_add(obj_gamehandler.entity_mapping, string(_data[3]), _a.id);
			obj_gamehandler.player_gm = _gm;
		} break;
			
		// 2 - Received Chat Message
		case 2: {
			// Print message to chat log.
			chat_print(_data[0]);
		} break;
			
		// 3 - Latency Test Response
		case 3: {
			// Subtract returned time from current time and set ping to the difference.
			var _sent = _data[0];
			var _received = current_time;
			obj_guihandler.ping = _received - _sent;
		} break;
			
		// 4 - Synchronization Call
		case 4: {
			// Synchronize time and UPS using data from server.
			obj_gamehandler.sec = _data[0];
			obj_gamehandler.tick = _data[1];
			obj_guihandler.server_ups = _data[2];
		} break;
			
		// 5 - Chunk Data Received
		case 5: {
			// Clear chunk request hold.
			obj_gamehandler.chunk_request_hold = false;
			
			// Get Location
			var _x = _data[0];
			var _y = _data[1];
		
			// If there is already a chunk at the location, exit. Otherwise, create a new chunk.
			var _a;
			if (!client_chunk_exists_at(_x, _y)) {
				_a = instance_create_layer(_x, _y, "Instances", obj_c_chunk);
			}
			else {
				exit;
			}
			
			// Unpack tilemaps
			var _gtm = num_array_unpack(_data[2]);
			var _ftm = num_array_unpack(_data[3]);
			var _stm =  num_array_unpack(_data[4]);
		
			// Populate chunk with tiledata
			array_to_chunk_tm(_gtm, _a.gtm);
			array_to_chunk_tm(_ftm, _a.ftm);
			array_to_chunk_tm(_stm, _a.stm);		
		} break;
			
		// 6 - Entity Loading
		case 6: {
			// Get entity type
			var _type = ds_map_find_value(global.entity_mapping, _data[2]);
		
			// Create Entity
			if (_type != noone) {
				var _x = _data[0];
				var _y = _data[1];
				var _inst = instance_create_layer(_x, _y, "Instances", _type);
				ds_map_add(obj_gamehandler.entity_mapping, string(_data[3]), _inst.id);
				_inst.server_id = string(_data[3]);
			}
		} break;
			
		// 7 - Destroy entity if destroyed on server.
		case 7: {
			// Find Entity
			var _instid = _data[0];
			var _inst = ds_map_find_value(obj_gamehandler.entity_mapping, string(_instid));
		
			// If entity exists, destroy it.
			if (instance_exists(_inst)) {
				instance_destroy(_inst);
			}
		} break;
			
		// 8 - Entity Moved (Common enough to warrant own protocol)
		case 8: {
			// Find Entity
			var _instid = _data[0];
			var _inst = ds_map_find_value(obj_gamehandler.entity_mapping, string(_instid));
			
			if (instance_exists(_inst)) {
				// Update Position
				_inst.x = _data[1];
				_inst.y = _data[2];
			}
		} break;
			
		// 9 - Entity Update
		case 9: {
			// Find Entity
			var _instid = _data[0];
			var _inst = ds_map_find_value(obj_gamehandler.entity_mapping, string(_instid));
	
			// Defer remaining data to entiy protocol handler.
			if (instance_exists(_inst)) {
				var _pid = _data[1];
				var _args = [];
				array_copy(_args, 0, _data, 2, array_length(_data) - 2);
				method_call(_inst.update_handler, [_pid, _args]);
			}
		} break;
			
		// 10 - Move own player.
		case 10: {
			if (instance_exists(obj_playerchar)) {
				obj_playerchar.x = _data[0];
				obj_playerchar.y = _data[1];
			}
		} break;
			
		// 11 - Chunk Update
		case 11: {
			// Find chunk
			var _chunk = client_get_chunk(_data[0], _data[1]);
			if (_chunk != noone) {
				// Update tilemap
				var _tm = variable_instance_get(_chunk, _data[2]);
				tilemap_set_at_pixel(_tm, _data[3], _data[0], _data[1]);
			}
		} break;
		
		// 12 - Gamemode Changed
		case 12: {
			obj_gamehandler.player_gm = _data[0];
		} break;
	}
}


/**
 * Handle input orders sent to a player on the server.
 *
 * @param {real} _protocol Data protocol to use.
 * @param {array} _args Input data to process.
 */
function input_protocols(_protocol, _args) {
	switch (_protocol) {
		case 0: { // Player Moved
			if (!data_array_is_valid(_args, ["number", "number"])) {
				exit;
			}
			
			// Set player movement orders.
			self.move_h = _args[0];
			self.move_v  = _args[1];
		} break;
		
		case 1: { // Build Input
			if (!data_array_is_valid(_args, ["bool", "number", "number"])) {
				exit;
			}
			
			// Set build input order and interaction coordinates, if applicable.
			self.build_input = _args[0];
			if (_args[0]) {
				self.interact_x = _args[1];
				self.interact_y = _args[2];
			}
		} break;
		
		case 2: { // Break Input
			if (!data_array_is_valid(_args, ["bool", "number", "number"])) {
				exit;
			}
			
			// Set build input order and interaction coordinates, if applicable.
			self.break_input = _args[0];
			if (_args[0]) {
				self.interact_x = _args[1];
				self.interact_y = _args[2];
			}
		} break;
		
		case 3: { // Pick up an item
			if (!data_array_is_valid(_args, ["string"])) {
				exit;
			}
			
			// Find item
			var _i = ds_map_find_value(obj_manager.entity_mapping, _args[0]);
			// Check that item exists, is an item, and is within interaction range.
			if (_i != undefined && _i.object_index = obj_itemstack && (distance_to_object(_i) <= 256 || self.game_mode)) {
				// Try to transfer item to the held slot first, then the player inventory.
				if (self.held_item.contents[0].stacksize > 0) {
					inventory_transfer(_i.contents, self.held_item, itemstack_copy(_i.contents.contents[0]));
				}
				inventory_transfer(_i.contents, self.player_inventory, itemstack_copy(_i.contents.contents[0]));
			}
		} break;
		
		case 4: { // Toggle Build Mode
			if (!data_array_is_valid(_args, ["bool"])) {
				exit;
			}
			
			// Set build mode to whatever the input is.
			self.floor_mode = _args[0];
		} break;
		
		case 5: { // Drop Item
			if (!data_array_is_valid(_args, ["number", "number", "bool"])) {
				exit;
			}
			
			// Get coordinates.
			self.interact_x = _args[0];
			self.interact_y = _args[1];
			
			// Drop item if item can be dropped (within interaction range, stack is greater than 0, and not over something).
			if (self.interact_in_range && self.held_item.contents[0].stacksize > 0 && !collision_point(self.interact_x, self.interact_y, [obj_par_entity, self.ts_chunk.stm], false, false)) {
				var _i = instance_create_depth(self.interact_x, self.interact_y, depth, obj_itemstack);
				if (_args[2]) {
					// Client held shift when dropping item, drop whole stack.
					inventory_transfer(self.held_item, _i.contents, itemstack_copy(self.held_item.contents[0]));
				}
				else {
					// Drop one item.
					var _t = itemstack_copy(self.held_item.contents[0]);
					_t.stacksize = 1;
					inventory_transfer(self.held_item, _i.contents, _t);
				}
			}
		} break;

		case 6: { // Inventory Manipulation
			if (!data_array_is_valid(_args, ["string","string","number","number","number"])) {
				exit;
			}
			
			// Get information
			var _sourcen = _args[0];
			var _targetn = _args[1];
			if (_sourcen == "null" || _targetn == "null") {
				// Exit if one or both inventories are not interface inventories.
				exit;
			}
			var _srcslot = _args[2];
			var _tslot = _args[3];
			var _count = _args[4];
			
			// Get Source Inventory
			var _source = undefined;
			if (_sourcen == "player_inventory" || _sourcen == "held_item") {
				// Source is own inventory.
				_source = variable_instance_get(self, _sourcen);
			}
			else {
				// Inventory is in interfacing entity.
				var _interface = ds_map_find_value(obj_server.interface_mapping, self.my_client);
				
				// Find inventrory.
				if (_interface != -1 && variable_instance_exists(_interface, _sourcen)) {
					_source = variable_instance_get(_interface, _sourcen);
				}
				else {
					// If no inventory can be found, exit.
					exit;
				}
			}
				
			// Get Target Inventory
			var _target = undefined;
			if (_targetn == "player_inventory" || _targetn = "held_item") {
				// Target is own inventory.
				_target = variable_instance_get(self, _targetn);				
			}
			else {
				// Get Interface Entity
				var _interface = ds_map_find_value(obj_server.interface_mapping, self.my_client);
				if (instance_exists(_interface)) {
					if (variable_instance_exists(_interface, _targetn)) {
						// Target provided, direct transfer.
						_target = variable_instance_get(_interface, _targetn);
					}
					else if (_targetn = "any") {
						// No target, find an inventory.
						var _i = array_concat([self.player_inventory], _interface.inventories);
						var _ii = [];
						var _si = [];
						// Look for inventories, sorting them based on type.
						for (var _j = 0; _j <= array_length(_i) - 1; _j++) {
							if (_i[_j].type = INVTYPES.INPUT) {
								_ii[array_length(_ii)] = _i[_j];
							}
							else if (_i[_j].type = INVTYPES.STORAGE) {
								_si[array_length(_si)] = _i[_j];
							}
						}
						
						// If source inventory is in array, remove it.
						if (array_length(_ii) > 0 && array_contains(_ii, _source)) {
							array_delete(_ii, array_get_index(_ii, _source), 1);
						}
						if (array_length(_si) > 0 && array_contains(_si, _source)) {
							array_delete(_si, array_get_index(_si, _source), 1);
						}
						
						// The break statement in these for loops tells the game to stop once a target is found.
						// Is there an input inventory avaliable?
						for (var _p = 0; _p < array_length(_ii) && is_undefined(_target); _p++) {
							if (array_contains(_ii[_p].params.whitelist, _source.contents[_srcslot].item_id)) {
								_target = _ii[_p];
							}
						}
						
						// If not, but the storage list has something, put it in the first inventory found.
						if (is_undefined(_target)) {
							if (array_length(_si) > 0) {
								_target = _si[0];
							}
							else {
								// If neither an input or storage inventory can be found, exit.
								exit;
							}
						}
					}
				}
				else {
					// If no inventory can be found, exit.
					exit;
				}
			}
			
			// Attempt to transfer items
			if (_target.type = INVTYPES.INPUT) {
				if (array_contains(_target.params.whitelist, _source.contents[_srcslot].item_id) || _source.contents[_srcslot].stacksize <= 0) {
					inventory_slot_transfer(_source, _srcslot, _target, _tslot, _count);
				}	
			}
			else {
				inventory_slot_transfer(_source, _srcslot, _target, _tslot, _count);
			}
		} break;
		
		case 7: { // Handcrafting
			if (!data_array_is_valid(_args, ["number"])) {
				exit;
			}
			
			// Get recipe, and set current recipe to it if it exists and the player has the right items.
			var _recipe = _args[0];
			if (_recipe != -1 && _recipe < array_length(global.recipe_registry) && inventory_has_items(self.player_inventory, global.recipe_registry[_recipe].inputs)) {
				// Set recipe to argument.
				self.current_recipe = _recipe;
			}
			// Otherwise, set the current recipe to nothing.
			else {
				// Cancel any existing recipe call.
				self.current_recipe = -1;
			}
		} break;
		
		case 8: { // Sandbox Item Selection
			if (!data_array_is_valid(_args, ["number", "number"])) {
				exit;
			}
			
			// Get the item and set the held item to it if the player is in sandbox mode and the item is valid.
			var _item = _args[0];
			if (self.game_mode && _item != -1 && _item < array_length(global.item_id)) {
				self.held_item.contents[0] = new ItemStack(_item, _args[1] ? global.item_id[_item].maxsize : (_item == self.held_item.contents[0].item_id ? self.held_item.contents[0].stacksize + 1: 1));
				send_inventory_update(0, self.held_item);
			}
		} break;
		
		case 9: { // Sandbox Tile Building
			if (!data_array_is_valid(_args, ["bool", "number", "number", "number", "number", "number"])) {
				exit;
			}
			
			// Set the build order and configure the build location and parameters.
			self.build_input = _args[0];
			self.interact_x = _args[1];
			self.interact_y = _args[2];

			if (_args[0] && _args[4] != -1 && instance_exists(ts_chunk)) {
				switch (_args[3]) {
					case 0: sb_tile_layer = [ts_chunk.gtm, "gtm"]; break;
					case 1: sb_tile_layer = [ts_chunk.ftm, "ftm"]; break;
					case 2: sb_tile_layer = [ts_chunk.stm, "stm"]; break;
				}

				sb_tile = _args[4];
				sb_brush_size = _args[5];
			}
		} break;
		
		case 10: { // Sign Update
			if (!data_array_is_valid(_args, ["string", "string"])) {
				exit;
			}
			
			// Find sign
			var _i = ds_map_find_value(obj_manager.entity_mapping, _args[0]);
			// Check that sign exists, is a sign, and is within interaction range.
			if (_i != undefined && _i.object_index = obj_sign && (distance_to_object(_i) <= 256 || self.game_mode)) {
				// Update text
				_i.my_text = _args[1];
				with (_i) {
					entity_send_update(0, [my_text]);
				}
			}
		} break;
	}
}