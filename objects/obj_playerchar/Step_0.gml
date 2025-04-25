/// @description Audio
// Update audio listener.
audio_listener_position(x, y, 0);

// If player moves, play footstep sound.
if ((x != xprev || y != yprev) && !obj_gamehandler.player_gm) {
	// Stop current sound if we changed tiles.
	var _toplay;
	var _curchunk = client_get_chunk(x, y);
	if (_curchunk != noone) {
		var _curtile = tilemap_get_at_pixel(_curchunk.gtm, x, y);

		// Get the appropriate footstep sound (should probably be delegated to a tile registry eventually).
		switch (_curtile) {
			case 1: _toplay = snd_footsteps_grass; break;
			case 2: _toplay = snd_footsteps_sand; break;
			case 3: _toplay = snd_footsteps_shallow_water; break;
			case 4: _toplay = snd_footsteps_deep_water; break;
			case 5: _toplay = snd_footsteps_stone; break;
			default: _toplay = undefined; 
		}
	}
	
	// Play said sound.
	if (_toplay != undefined && (footstep_sound == undefined || !audio_is_playing(footstep_sound))) {
		footstep_sound = audio_play_sound(_toplay, 1, false, 1, 0, 0.8 + (0.2 * step_pattern));
		step_pattern = !step_pattern;
	}
}
xprev = x;
yprev = y;