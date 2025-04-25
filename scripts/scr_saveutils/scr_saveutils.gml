/**
* Load the game from the current save file.
*/
function load_game() {
	// Setup
	var _savefile = global.current_save;
	
	// Load general info.
	if (file_exists(_savefile + "/worldinfo.json")) {
		var _geninfo = load_json(_savefile + "/worldinfo.json");
		
		global.map_type = (struct_exists(_geninfo, "maptype") ? _geninfo.maptype : 0);
		global.default_gm = (struct_exists(_geninfo, "default_gm") ? _geninfo.default_gm : 0);
		random_set_seed(struct_exists(_geninfo, "seed") ? _geninfo.seed : randomize());
		obj_manager.sec = (struct_exists(_geninfo, "time")) ? _geninfo.time : 480;
		obj_manager.playtime = (struct_exists(_geninfo, "playtime")) ? _geninfo.playtime : 0;
	}
}

/**
* Save current game state to world file.
*/
function save_game() {
	// Start saving process.
	console_log(0, "Saving world...");
	var _start = current_time;
	var _savefile = global.current_save;
	
	// Update manifest.json.
	// Fetch and format data.
	var _playtimesec =  instance_exists(obj_manager) ? obj_manager.playtime : obj_pausehandler.cached_sp_playtime;
	var _date = (global.settings.date_format) ? get_date_mmdd() : date_date_string(date_current_datetime());
	var _hours = clamp(floor(_playtimesec / 3600), 0, infinity);
	var _minutes = round(_playtimesec / 60) % 60;
	var _playtime = string("{0}hrs {1}mins", _hours, _minutes);

	// Save data to file.
	save_json({
			date : _date,
			version : global.game_version,
			playtime :  _playtime,
		},
		_savefile + "/manifest.json"
	);
	
	// Save general world info.
	save_json({
		maptype : global.map_type,
		default_gm : global.default_gm,
		seed : random_get_seed(),
		time :  obj_manager.sec,
		playtime : obj_manager.playtime 
	},
	_savefile + "/worldinfo.json"
	);
	
	// Save player data.
	var _player = ds_map_find_first(obj_server.playerdata_mapping);
	for (var _i = 0; _i < ds_map_size(obj_server.playerdata_mapping); _i++) {
		save_player_data(_player);
		_player = ds_map_find_next(obj_server.playerdata_mapping, _player);
	}
	
	// Save chunks.
	with (obj_chunk) {
		save_chunk(self);
	}
	
	// End saving process.
	var _savetime = current_time - _start;
	console_log(0, string("World save finished in {0}ms.", _savetime));
}

/**
* Save data for a specific player.
*
* @param {Id.Instance} _player Player whose data to save.
*/
function save_player_data(_player) {
	// Get playerdata key.
	var _key = ds_map_find_value(obj_server.playerdata_mapping, _player);
	
	// Resolve data directory and files.
	var _pd = global.current_save + "/playerdata/" + string(_key);
	var _invdata = _pd + "/inventory.dat"
	
	// Save player information
	var _info = {
		x : _player.x,
		y : _player.y,
		gm : _player.game_mode
	}
	
	save_json(_info, _pd + "/playerdata.json");

	// Create inventory data struct.
	var _inv = {
		main : _player.player_inventory.contents,
		held : _player.held_item.contents
	}
	
	// Write inventory struct to buffer and compress it.
	var _tosave = buffer_create(1, buffer_grow, 1);
	buffer_prepare(_tosave, _inv);
	_tosave = buffer_compress(_tosave, 0, buffer_tell(_tosave));
	
	// Save buffer to file.
	buffer_save(_tosave, _invdata);
}

/**
* Save the contents of a chunk to its corresponding file.
*
* @param {Id.Instance} _chunk Chunk whose data to save.
*/
function save_chunk(_chunk) {
	// Pull chunk coordinates
	var _cx = _chunk.chunk_x;
	var _cy = _chunk.chunk_y;
	
	// Resolve save location.
	var _wd = global.current_save + "/world/";
	var _sf = _wd + string("{0}_{1}.dat",  chunk_x, chunk_y);
	
	// Get entities
	var _chunkentities = ds_list_create();
	collision_rectangle_list(_chunk.x, _chunk.y, _chunk.x + 511, _chunk.y + 511, obj_par_entity, false, true, _chunkentities, false);
	
	// Save entity data.
	var _entities = [];
	for (var _i = 0; _i < ds_list_size(_chunkentities); _i++) {
		var _entity = ds_list_find_value(_chunkentities, _i);
		
		// If this is a player, skip.
		if (_entity.object_index == obj_player) {
			continue;
		}
		
		// Get instance variables (exclude methods)
		var _names = variable_instance_get_names(_entity);
		var _values = [];
		for (var _j = 0; _j < array_length(_names); _j++) {
			var _value = variable_instance_get(_entity, _names[_j]);
			if (is_method(_value)) {
				array_delete(_names, _j, 1);
				_j--;
			}
			else {
				_values[_j] = _value;
			}
		}
		
		// Add entity data to list.
		array_push(_entities, {
			obj : object_get_name(_entity.object_index),
			x : _entity.x,
			y : _entity.y,
			n : _names,
			v : _values
		});
	}
	
	// Free list.
	ds_list_destroy(_chunkentities);

	// Save chunk data to struct
	var _data = {
		e : _entities,
		g : chunk_tm_to_array(_chunk.gtm),
		f : chunk_tm_to_array(_chunk.ftm),
		s : chunk_tm_to_array(_chunk.stm)
	}
	
	// Write data to buffer and compress it.
	var _tosave = buffer_create(1, buffer_grow, 1);
	buffer_prepare(_tosave, _data);
	_tosave = buffer_compress(_tosave, 0, buffer_tell(_tosave));
	
	// Save buffer to file.
	buffer_save(_tosave, _sf);
}

/**
* Attempt to load a chunk from a file, and generate a new one if it doesn't exist.
*
* @param {real} _chunk_x Chunk x-coordinate to look for.
* @param {real} _chunk_y Chunk y-coordinate to look for.
*/
function load_chunk(_chunk_x, _chunk_y) {
	// Create chunk.
	var _chunk;
	_chunk = instance_create_layer(_chunk_x * 512, _chunk_y * 512, "Server", obj_chunk);
	_chunk.chunk_x = _chunk_x;
	_chunk.chunk_y = _chunk_y;
	
	// Load chunk data if it exists.
	var _file = global.current_save + "/world/" + string("{0}_{1}.dat", _chunk_x, _chunk_y);
	if (file_exists(_file)) {
		// Extract struct from buffer.
		var _cd = buffer_load(_file);
		_cd = buffer_decompress(_cd);
		var _data = read_data(_cd);
		
		// Load chunk data.
		array_to_chunk_tm(_data.g, _chunk.gtm);
		array_to_chunk_tm(_data.f, _chunk.ftm);
		array_to_chunk_tm(_data.s, _chunk.stm);
		
		for (var _i = 0; _i < array_length(_data.e); _i++) {
			var _e = instance_create_layer(_data.e[_i].x, _data.e[_i].y, "Server", asset_get_index(_data.e[_i].obj));
			// Set entity variables.
			for (var _j = 0; _j < array_length(_data.e[_i].n); _j++) {
				// Set all values that are not the inventory tracker (will eventually find a way to exclude object-scope variables from this).
				if (_data.e[_i].n[_j] != "inventories") {
					// If this is not an inventory, set it as normal.
					if (!is_struct(_data.e[_i].v[_j]) || !struct_exists(_data.e[_i].v[_j], "contents")) {
						variable_instance_set(_e, _data.e[_i].n[_j], _data.e[_i].v[_j]);
					}
					// Otherwise, just copy the contents.
					else {
						variable_instance_get(_e, _data.e[_i].n[_j]).contents = _data.e[_i].v[_j].contents;
					}
				}
			}
		}
	}
	// If no data exists, call the world generation event.
	else {
		with (_chunk) {
			event_user(0);
		}
	}
}