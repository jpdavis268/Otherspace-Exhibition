/// @description Setup
event_inherited();
my_text = "";
cached_text = my_text;
has_gui = true;
input_position = 0;
input_position_offset = 0;
line = 0;

done_button = new Button(100, 48, "Done", function() {keyboard_key_press(vk_escape)});

my_gui = new GUI(0, 0, 300, 204, function() {
	// Draw Base
	draw_rectangle_color(4, 4, 296, 148, c_black, c_black, c_black, c_black, false);
	
	// Buttons
	done_button.draw(150, 176);
	
	// Handle User Input
	// Draw current text.
	draw_set_font(fnt_main_large);
	draw_set_halign(fa_center);
	var _f = string_copy(cached_text, 0, input_position);
	var _width = string_width(_f);
	var _editlines = string_split(_f, "\n");
	var _alllines = string_split(cached_text, "\n");
	var _cx = string_width(array_last(_editlines)) - 2;
	var _cy =  36 * (array_length(_editlines) - 1);
	draw_text(150, 4, cached_text);
	draw_set_halign(fa_left);
	draw_text(150 - (string_width(_alllines[array_length(_editlines) - 1]) / 2) + _cx, clamp(_cy, 0, 999), global.field_cursor);
	draw_set_font(fnt_main);
	
	// Handle text input.
	if (keyboard_lastkey != vk_nokey) {
		// This still can't handle most unicode characters!
		if (is_in_range(ord(keyboard_lastchar), 32, 255)) {
			if (string_width(array_last(_editlines)) < 136) {
				cached_text = string_insert(keyboard_lastchar, cached_text, input_position + 1);
			}
			else {
				keyboard_key_press(vk_enter);
			}
		}
		else {
			switch (keyboard_lastkey) {
				// Backspace
				case (vk_backspace): {
					if (input_position != 0 && (!string_ends_with(_f, "\n") || input_position_offset == 0)) {
						cached_text = string_delete(cached_text, input_position, 1);
					}
				} break;
				case (vk_enter): {
					if (string_height(cached_text) < 66 && string_width(array_last(_editlines)) > 0) {
						cached_text = string_insert("\n", cached_text, input_position + 1);
					}
				} break;
				// Move cursor left
				case (vk_left): {
					if !(-input_position_offset >= string_length(cached_text)) {
						input_position_offset--;
					}
				} break;
				// Move cursor right
				case (vk_right): {
					if (input_position_offset < 0) {
						input_position_offset++;
					}
				} break;
			}
		}
		keyboard_lastchar = "";
		keyboard_lastkey = vk_nokey;
		input_position = string_length(cached_text) + input_position_offset;
	}
});

// Update Handler
update_handler = function (_protocol, _data) {
	switch (_protocol) {
		case 0: { // Text Changed
			my_text = _data[0];
			cached_text = my_text;
		} break;
	}
}