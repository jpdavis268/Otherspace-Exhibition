/// @description Game Management
// Chunk Loading and Unloading
var _clog = [];
var _missingchunks = [];
if (instance_exists(obj_playerchar)) {
	// Only run this if the player character is initialized.
	for (var _i = 0; _i <= 5; _i++) {
		var _cx1 = (floor(obj_playerchar.x / 512) * 512) - (512 * _i);
		var _cy1 = (floor(obj_playerchar.y / 512) * 512) - (512 * _i);
		var _d = (_i * 2) + 1;
		for (var _j = 0; _j < _d; _j++) {
			for (var _k = 0; _k < _d; _k++) {
				if (_j == 0 || _k == 0 || _j == _d - 1 || _k == _d - 1) {
					var _tx = _cx1 + (512 * _j);
					var _ty = _cy1 + (512 * _k);
					if (client_chunk_exists_at(_tx, _ty)) {
						// Chunk is here, so log it
						array_insert(_clog, array_length(_clog), instance_position(_tx, _ty, obj_c_chunk));
					}
					else {
						// No loaded chunk exists here, add expected location to array
						array_insert(_missingchunks, array_length(_missingchunks), [floor(_tx / 512) * 512, floor(_ty / 512) * 512]);
					}
				}
			}
		}
	}
}
	
// Unload chunks not in range
// Check to see if there are more chunks than there are supposed to be.
if (instance_number(obj_c_chunk) > 121) {
	// Compare chunk instance IDs in array to all chunk instance IDs and delete those not in the array
	for (var _i = 0; _i < instance_number(obj_c_chunk); _i++) {
		var _inst = instance_find(obj_c_chunk, _i);
		if (!array_contains(_clog, _inst)) {
			instance_destroy(_inst);
		}
	}
}

// Request information on missing chunks from server, if there are any.
if (array_length(_missingchunks) > 0) {
	// Send request for a chunk if we are not on hold.
	if (!chunk_request_hold && !global.paused) {
		client_send_data([3, _missingchunks[0][0], _missingchunks[0][1]]);
		chunk_request_hold = true;
		chunk_request_timeout = 300;
	}
	// Decrement timeout.
	if (chunk_request_timeout > 0) {
		chunk_request_timeout--;
	}
	else {
		// If timeout runs out, cancel hold.
		chunk_request_hold = false;
	}
}

// Time Management
// Increment seconds if we are not paused or not in singleplayer.
if (!global.paused || obj_control.game_type != 0) {
	tick++;
}
// If we have reached 60 ticks, increment seconds and reset ticks.
if (tick >= 60) {
	sec++
	tick = 0;
}
	
// Formatted values
day = floor((sec / 1440) + 1);
var _tm = (floor(sec / 60)) - (24 * (day - 1));
var _ts = (sec - (_tm * 60)) - (1440 * (day - 1));
var _m;
var _s;

// Format minutes.
if (_tm < 10) {
	_m = "0" + string(_tm);
}
else {
	_m = string(_tm);
}

// Format seconds.	
if (_ts < 10) {
	_s = "0" + string(_ts);
}
else {
	_s = string(_ts);
}

// Formatted time
if (global.settings.time_format = 0) {
	// AM/PM
	if (_tm = 0) {time = ("12:" + _s + " AM")}
	else if (_tm < 12) {time = (_m + ":" + _s + " AM")}
	else if (_tm = 12) {time = ("12:" + _s + " PM")}
	else if (_tm > 12) {time = (string(_tm - 12) + ":" + _s + " PM")}
}
else {
	// 24 hour
	time = (_m + ":" + _s);
}

// Day phase
if (_tm < 6 || _tm >= 22 ) {day_phase = get_text("hud_night")}
else if (_tm < 9) {day_phase = get_text("hud_early_morning")}
else if (_tm < 12) {day_phase = get_text("hud_late_morning")}
else if (_tm < 15) {day_phase = get_text("hud_early_afternoon")}
else if (_tm < 18) {day_phase = get_text("hud_late_afternoon")}
else if (_tm < 20) {day_phase = get_text("hud_evening")}
else if (_tm < 22) {day_phase = get_text("hud_dusk")}

// Daylight
if (is_in_range(_tm, 20, 21)) {
	// Dusk
	obj_lighthandler.light_level = 0.95 - ((((sec - (1440 * (day - 1)) - 1200)) * 0.75) / 100);
}
else if (_tm < 6 || _tm >= 22) {
	// Night
	obj_lighthandler.light_level = 0.05;
}
else if (_tm < 9) {
	// Dawn
	obj_lighthandler.light_level = 0.1 + ((((sec - (1440 * (day - 1)) - 360)) * 0.33) / 100);
}
else {
	// Day
	obj_lighthandler.light_level = 1;
}

// Ambience
if (!audio_is_playing(snd_forestambienceday)) {
	audio_play_sound(snd_forestambienceday, 1, true);
	audio_play_sound(snd_forestambiencenight, 1, true);
}

// Dynamic Ambience
audio_sound_gain(snd_forestambienceday, obj_lighthandler.light_level - 0.05, 0);
audio_sound_gain(snd_forestambiencenight, 1 - obj_lighthandler.light_level, 0);

// Gamemode management
if (!player_gm) {
	obj_inputhandler.current_sb_tile_sel = [ts_ground, -1];
}