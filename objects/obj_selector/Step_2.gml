/// @description Selector Management
// Get In-Game Coordinates of Mouse
var _xtile = floor(mouse_x / 32);
var _ytile = floor(mouse_y / 32);

// Place selector at in-game coordinates (and also manually set previous x and y position as the end step event seems to break it)
true_xp = x;
true_yp = y;
x = (_xtile * 32) + 16;
y = (_ytile * 32) + 16;

// Update TS Chunk
ts_chunk_exists = client_chunk_exists_at(x, y);

// Reset destroy progress if moved
if (true_xp != x || true_yp != y) {
	destroy_progress = 0;
}

// Determine if selector is in range (override if in sandbox mode)
if (distance_to_object(obj_playerchar) <= 256 || obj_gamehandler.player_gm) {
	within_range = true;
}
else {
	within_range = false;
}
	
// Show text flash if we attempt to do something outside of interaction range.
if ((mouse_check_button_pressed(1) || mouse_check_button_pressed(2)) && !within_range && global.player_control) {
	instance_create_depth(x, y, depth, obj_textflash, {text : get_text("ui_selector_outofrange")});
}
	
// Keep above rest of game
depth = -10000;