/// @description Footsteps
event_inherited();
audio_emitter_position(audio_emitter, x, y, 0);

// If entity moves, play footstep sound.
if (!silent && (x != xprev || y != yprev)) {
	// Stop current sound if we changed tiles.
	var _curchunk = client_get_chunk(x, y);
	var _toplay;
	
	if (_curchunk != noone) {
		var _curtile = tilemap_get_at_pixel(_curchunk.gtm, x, y);
	
		// Get the appropriate footstep sound.
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
		footstep_sound = audio_play_sound_on(audio_emitter, _toplay, false, 1, 1, 0,  0.8 + (0.2 * step_pattern));
		step_pattern = !step_pattern;
	}
}
xprev = x;
yprev = y;
