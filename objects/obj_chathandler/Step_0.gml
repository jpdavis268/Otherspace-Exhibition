/// @description Chat Management
// Chat scrolling
// Only check the scroll wheel if it is visible (chat is shown and large enough to warrant it).
if (chat_window <= 400 && chat_enabled) {
	// Scrolling up
	if (mouse_wheel_up()) {
		if ((scroll_center - scroll_range) - 10 > -1) {
			// If we aren't up against the top, raise the scoll bar.
			scroll_position -= 10;
		}
		else {
			// If we are close to the top, only raise the scroll bar by the remaining distance.
			scroll_position -= (scroll_center - scroll_range);
		}
	}
	// Scrolling down
	if (mouse_wheel_down()) {
		if ((scroll_center + scroll_range) + 10 < 401) {
			// If we aren't close to the bottom, lower the scroll bar.
			scroll_position += 10;
		}
		else {
			// Otherwise, only lower it by the remaining distance.
			scroll_position += (400 - (scroll_center + scroll_range));
		}
	}
	// Reset scroll position if middle click is pressed.
	if (mouse_check_button(3)) {
		scroll_position = 0;
	}
	// Allow for mouse manipulation if we are over the scroll bar or have it selected.
	if (is_in_range(window_mouse_get_x(), 800, 810) && is_in_range(window_mouse_get_y(), (display_get_gui_height() / 2) - 200, (display_get_gui_height() / 2) + 200) || scroll_mouse_selected) {
		scroll_color = c_ltgray;
		if (mouse_check_button(1)) {
			scroll_mouse_selected = true;
		}
	}
	else {
		scroll_color = c_gray;
	}
	// Make scroll bar follow mouse while selected.
	if (scroll_mouse_selected) {
		var _r = (display_get_gui_height() / 2) + 200;
		scroll_position = (window_mouse_get_y() - (_r)) + scroll_range;
		scroll_position = clamp(scroll_position, -400 + scroll_range * 2, 0);
		// If the mouse is released, deselect the scroll wheel.
		if (!mouse_check_button(1)) {
			scroll_mouse_selected = false;
		}
	}
}

// Chat message typing and sending
if (chat_enabled) {
	// Typing
	if (keyboard_lastkey != vk_nokey) {
		// Only accept input if message lengh is less than 256 characters, and the character is a valid glyph.
		// (This only covers ASCII, need to update it to support other alphabets).
		if (is_in_range(ord(keyboard_lastchar), 32, 255) && string_length(chat_text_currentline) < 256) {
			chat_text_currentline = string_insert(keyboard_lastchar, chat_text_currentline, input_position + 1);
		}
		// If this is not a glyph, check to see if it a valid control key.
		else {
			switch (keyboard_lastkey) {
				case (vk_backspace): {
					if (input_position != 0) {
						chat_text_currentline = string_delete(chat_text_currentline, input_position, 1);
					}
				} break;
				case (vk_left): { // Move cursor left
					if !(-input_position_offset >= string_length(chat_text_currentline)) {
						input_position_offset--;
					}
				} break;
				case (vk_right): { // Move cursor right
					if (input_position_offset < 0) {
						input_position_offset++;
					}
				} break;
				case (vk_up): { // Go back through input history
					if (array_length(input_history_) > history_scroll + 1) {
						history_scroll++;
						chat_text_currentline = input_history_[history_scroll];
					}
				} break;
				case (vk_down): { // Go up through input history
					if (history_scroll - 1 > -1) {
						history_scroll--;
						chat_text_currentline = input_history_[history_scroll];
					}
				} break;
			}
		}
		// Reset input.
		keyboard_lastchar = "";
		keyboard_lastkey = vk_nokey;
		input_position = string_length(chat_text_currentline) + input_position_offset;
	}
	// Send message
	if (keyboard_check_pressed(vk_enter) && string_length(chat_text_currentline) > 0 && string_count(" ", chat_text_currentline) != string_length(chat_text_currentline)) {
		// Reset current input position
		input_position = 0;
		input_position_offset = 0;
		
		// Increment sent message history.
		history_scroll = 0;
		for (var _i = array_length(input_history_) - 1; _i >= 0; _i--) {
			input_history_[_i + 1] = input_history_[_i];
		}
		input_history_[1] = chat_text_currentline;
		
		if (string_char_at(chat_text_currentline, 1) != "/") {
			// Chat Message
			chat_send(chat_text_currentline);
		}
		else {
			// Console Command
			client_send_data([6, chat_text_currentline])
		}
		chat_text_currentline = "";
		chat_enabled = false;
		global.player_control = true;
	}
}
	
// Handle Recent Chat Messages
for (var _i = 1; _i < array_length(chat_recent_); _i++) {
	chat_recent_[_i]--;
}
if (array_last(chat_recent_) < 1) {
	// Clear older messages;
	array_delete(chat_recent_, array_length(chat_recent_) - 1, 1);
}	