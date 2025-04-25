/// @description Setup
// Rendering Settings
player_username = ""; // Our username on the server.

// Time
day = 0; // Current Day
time = "8:00 AM"; // Time to display on HUD.
day_phase = get_text("hud_early_morning"); // Time of day.
sec = 480; // Seconds
tick = 0; // Ticks elapsed since last second.

// Network Stats
network_in = 0; // Running total of data received since last second.
network_out = 0; // Running total of data sent since last second.
data_sent = 0; // Total data sent last second.
data_received = 0; // Total data received last second.
alarm[0] = 60; // Alarm for resetting data.

// General
global.player_control = true; // Whether player can input actions.
entity_mapping = ds_map_create(); // Track Entities
chunk_request_hold = false; // Whether or not we can send a request for chunk loading.
chunk_request_timeout = 300; // Track how long it has been since the last chunk request was sent.
player_gm = 0; // Player gamemode