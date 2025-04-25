/// @description Animation Controls
event_inherited();
// Show fire if active
if (active) {
	image_speed = 1;
	if (image_index >= image_number) {
		image_index = 2;
	}
}
else {
	// If not active, show the inactive sprite.
	image_index = 0;
	image_speed = 0;
}

// Flickering
// Reverse flicker direction if we are at a bound.
if (range < 0.097 || range > 0.103) {
	flicker_dir = -flicker_dir;
}

range += 0.0002 * flicker_dir;

// Audio management
audio_emitter_position(audio_emitter, x, y, 0);
if (active && active_sound == undefined) {
	active_sound = audio_play_sound_on(audio_emitter, snd_firepit, true, 1);
}
else if (!active && active_sound != undefined) {
	audio_stop_sound(active_sound);
}