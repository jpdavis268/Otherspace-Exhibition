/// @description Audio stuff
event_inherited();
silent = false; // Whether this entity makes noise.
footstep_sound = undefined; // Footstep
last_tile = -1; // Last tile
step_pattern = false;
audio_emitter = audio_emitter_create(); // Audio emitter.
audio_emitter_falloff(audio_emitter, 256, 1024, 1); // Emitter falloff factor.

// Fixed previous coordinates (built in ones break in multiplayer).
xprev = x;
yprev = y;
