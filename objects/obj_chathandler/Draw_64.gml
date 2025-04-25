/// @description Render Chat
// Get GUI dimensions
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Render chat
if (chat_enabled) {
	// Create drawing surfaces
	var _chat_input_surface = surface_create(800, 20);
	var _chat_history_surface = surface_create(810, 400);
	
	// Draw chat history
	// Draw box
	surface_set_target(_chat_history_surface);
	draw_set_alpha(0.6);
	draw_rectangle_color(0, 0, 799, 400, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	// Draw text
	var _text_lines = array_length(chat_text_);
	var _line_size;
	draw_set_valign(fa_bottom);
	for (var _i = 0; _i < _text_lines; _i++) {
		draw_text_ext(0, (400 - last_line_size) + chat_window_floor, string(chat_text_[_i]), -1, 800);
		last_line_size += string_height_ext(chat_text_[_i], -1, 800);
	}
	var _loglength = last_line_size;
	last_line_size = 0;
	// Draw scroll bar
	chat_window = (400 / (_loglength)) * 400;
	scroll_range = chat_window / 2;
	scroll_center = (-scroll_range + 400) + scroll_position;
	if (chat_window <= 400) {
		// If chat history is larger than window, enable scrolling.
		chat_window_floor = _loglength - (_loglength * (((scroll_center + scroll_range) / 400)));
		draw_rectangle_color(800, scroll_center - scroll_range, 810, scroll_center + scroll_range, scroll_color, scroll_color, scroll_color, scroll_color, false);
	}
	else {
		// Otherwise, lock the window to the bottom.
		chat_window_floor = 0;
	}
	surface_reset_target();
	
	// Draw current text input
	surface_set_target(_chat_input_surface);
	draw_set_alpha(0.8);
	draw_rectangle_color(0, 0, 800, 20, c_black, c_black, c_black, c_black, false);
	draw_reset();
	var _c = string_copy(chat_text_currentline, 0, input_position);
	if (string_width(_c) < 750) {
		// If input can fit within the box, draw it normally.
		draw_text(0, 0, string(chat_text_currentline));
		draw_text(string_width(_c) - 1, 0, global.field_cursor);
	}
	else {
		// Otherwise, draw the section around the cursor.
		draw_text((0 - (string_width(_c)) + 750), 0, string(chat_text_currentline));
		draw_text((0 - (string_width(_c)) +750) + (string_width(_c) - 1), 0, global.field_cursor);
	}
	surface_reset_target();
	
	// Draw input and history surfaces
	draw_surface(_chat_history_surface, 0, (_gh / 2) - 200);
	draw_surface(_chat_input_surface, 0, (_gh / 2) + 200);
	surface_free(_chat_history_surface);
	surface_free(_chat_input_surface);
}
else {
	// Draw recent messages if chat is not enabled
	// Create surface
	var _chat_recent_surface = surface_create(800, 400);
	surface_set_target(_chat_recent_surface);
	// Draw text
	var _text_lines = array_length(chat_recent_) - 1;
	var _line_size;
	draw_set_valign(fa_bottom);
	for (var _i = 0; _i < _text_lines; _i++) {
		if (chat_recent_[_i + 1] < 120) {
			draw_set_alpha(1 * chat_recent_[_i + 1] / 120)
		}
		draw_text_ext(0, (400 - last_line_size), string(chat_text_[_i]), -1, 800);
		last_line_size += string_height_ext(chat_text_[_i], -1, 800);
		draw_set_alpha(1)
	}
	last_line_size = 0;
	draw_set_valign(fa_top);
	surface_reset_target();
	
	// Draw recent chat surface
	draw_surface(_chat_recent_surface, 0, (_gh / 2) - 200);
	surface_free(_chat_recent_surface);
}