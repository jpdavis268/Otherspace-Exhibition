/**
 * Parent class for GUI components.
 *
 * @param {real} _width Component width.
 * @param {real} _height Component height.
 */
function Component(_width, _height) constructor {
	width = _width;
	height = _height;
	
	function draw(_x, _y) {};
}

/**
 * Simple button, runs an action when clicked.
 *
 * @param {real} _width Button width.
 * @param {real} _height Button height.
 * @param {string} _text Button label.
 * @param {function} _action Code to run when button is pressed.
 */
function Button(_width, _height, _text, _action, _hovertext = "") : Component(_width, _height) constructor {
	text = _text;
	action = _action;
	default_color = c_gray;
	over_color = c_ltgray;
	hover_text = _hovertext;
	
	function draw(_x, _y, _mousefloor = window_get_height(), _guiman_override = false) {
		// Prepare drawing configuration.
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _xdist = width / 2;
		var _ydist = height / 2;
	
		// Draw button and handle mouse actions.
		if (window_mouse_get_y() < _mousefloor && mouse_is_over(_x - _xdist, _y - _ydist, _x + _xdist, _y + _ydist, true, _guiman_override)) {
			// Mouse is over button.
			draw_rectangle_color(_x - _xdist, _y - _ydist, _x + _xdist, _y + _ydist, over_color, over_color, over_color, over_color, false);
			global.hover_text = hover_text;
			if (mouse_check_button_pressed(1)) {
				// Call action if player clicks while over mouse.
				audio_play_sound(snd_uisel, 1, false);
				method_call(action, []);
				mouse_clear(1);
			}
		}
		else {
			// Mouse is not over button.
			draw_rectangle_color(_x - _xdist, _y - _ydist, _x + _xdist, _y + _ydist, default_color, default_color, default_color, default_color, false);
		}
		// Draw label.
		draw_text(_x, _y, get_text(text));
		
		// Reset drawing configuration.
		draw_reset();
	}
}

/**
 * Toolbar that allows user to click on a list of tabs.
 *
 * @param {real} _width Toolbar width.
 * @param {real} _height Toolbar height.
 * @param {array<string>} _labels Labels to put on toolbar (number of labels also controls number of tabs).
 */
function Toolbar(_width, _height, _labels) : Component(_width, _height) constructor {
	labels = _labels;
	selected_tab = 0;
	default_color = c_gray;
	over_color = c_ltgray;
	
	function draw(_x, _y) {
		// Draw background
		draw_rectangle_color(_x, _y, _x + width, _y + height, default_color, default_color, default_color, default_color, false);
		
		// Draw tabs
		var _tabwidth = width / array_length(labels);
		for (var _i = 0; _i < array_length(labels); _i++) {
			// Select default color.
			var _color = (selected_tab == _i) ? over_color : default_color;
			
			// Check each tab to see if mouse is on it.
			var _tx = _x + _tabwidth * _i;
			if (mouse_is_over(_tx, _y, _tx + _tabwidth, _y + height, true) && selected_tab != _i) {
				_color = over_color;
				if (mouse_check_button_pressed(1)) {
					audio_play_sound(snd_uisel, 1, false);
					selected_tab = _i;
				}
			}
			
			// Draw tab
			draw_rectangle_color(_tx, _y, _tx + _tabwidth, _y + height, _color, _color, _color, _color, false);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_tx + _tabwidth / 2, _y + height / 2, get_text(labels[_i]));
			draw_reset();
		}
	}
}

/**
 * Slider, allows for a point to be moved back and forth.
 *
 * @param {real} _width Slider width.
 * @param {string} _label Slider label.
 * @param {function} _updateaction Code to run when slider is moved.
 * @param {real} _startingvalue Starting position of slider, from 0 to 1.
 */
function Slider(_width, _label, _updateaction, _startingvalue = 0) : Component(_width, 40) constructor {
	label = _label;
	position = _startingvalue;
	updateaction = _updateaction;
	mouse_is_dragging = false;
	static other_selected = false;
	
	function draw(_x, _y) {
		// Label
		draw_reset();
		draw_text(_x, _y, get_text(label));
		
		// Slide bar
		draw_rectangle_color(_x, _y + 28, _x + width, _y + 32, c_gray, c_gray, c_gray, c_gray, false);
		
		// Notch
		var _offset = position * width;
		draw_rectangle(_x + _offset - 3, _y + 20, _x + _offset + 3, _y + 40, false);
		
		// Handle mouse dragging.
		var _rx = (instance_exists(obj_guihandler) && obj_guihandler.current_gui != noone) ? obj_guihandler.gui_surf_x : 0;
		if ((mouse_is_over(_x, _y + 20, _x + width, _y +  40, true) && !Slider.other_selected) || mouse_is_dragging) {
			// If the player clicks while over the slider, start dragging it.
			if (mouse_check_button(1)) {
				mouse_is_dragging = true;
				Slider.other_selected = true;
				var _mx = window_mouse_get_x();
				position = clamp(_mx - _x - _rx, 0, width) / width;
				method_call(updateaction);
			}
			else {
				mouse_is_dragging = false;
				Slider.other_selected = false;
			}
		}
	}
}

/**
* Single line user input field.
*
* @param {real} _width Field width.
* @param {string} _startingtext Intial field text.
* @param {Constant.Color} _unselectedcol What color the field should be when not selected.
* @param {Constant.Color} _selectedcol What color the field should be when selected.
* @param {Constant.Color} _outlinecol What color the field outline should be.
*/
function InputField(_width, _startingtext = "", _unselectedcol = c_black, _selectedcol = c_dkgray, _outlinecol = c_ltgray) : Component(_width, 20) constructor {
	stored_text = _startingtext;
	unsel_col = _unselectedcol;
	sel_col = _selectedcol;
	out_col = _outlinecol;
	cur_col = unsel_col;
	selected = false;
	input_position = 0;
	input_position_offset = 0;
	
	function draw(_x, _y) {
		// Handle selection
		if (mouse_check_button_pressed(1)) {
			var _alreadyselected = selected;
			selected = (mouse_is_over(_x, _y, _x + width, _y + 20, true));
			if (selected && !_alreadyselected) {
				input_position = string_length(stored_text);
			}
		}
		
		// Unselect this field if ESC or Enter is pressed
		if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
			selected = false;
		}
		
		// Draw back
		cur_col = selected ? sel_col : unsel_col;
		draw_rectangle_color(_x, _y, _x + width, _y + 20, cur_col, cur_col, cur_col, cur_col, false);
		draw_rectangle_color(_x, _y, _x + width, _y + 20, out_col, out_col, out_col, out_col, true);
		
		// Draw input field
		var _field_input_surface = surface_create(width, 20);
		surface_set_target(_field_input_surface);
		var _f = string_copy(stored_text, 0, input_position);
		// Draw input field, pushing out beginning if the text exceeds the size of the box.
		var _tx = clamp(0 - string_width(_f) + 480, -1000, 0);
		draw_text(_tx, 0, string(stored_text));
		if (selected) {
			draw_text(_tx + string_width(_f) - 1, 0, global.field_cursor);
		}
		surface_reset_target();
		draw_surface(_field_input_surface, _x, _y);
	
		// If not selected, do nothing.
		if (!selected) {
			input_position_offset = 0;
			exit;
		}
	
		// Handle text input.
		if (keyboard_lastkey != vk_nokey) {
			// This also can't handle most unicode characters!
			if (is_in_range(ord(keyboard_lastchar), 32, 255) && string_length(stored_text) < 32) {
				stored_text = string_insert(keyboard_lastchar, stored_text, input_position + 1);
			}
			else {
				switch (keyboard_lastkey) {
					// Backspace
					case (vk_backspace): {
						if (input_position != 0) {
							stored_text = string_delete(stored_text, input_position, 1);
						}
					} break;
					// Move cursor left
					case (vk_left): {
						if !(-input_position_offset >= string_length(stored_text)) {
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
			input_position = string_length(stored_text) + input_position_offset;
		}
	
		// Cleanup
		surface_free(_field_input_surface);
	}
}
	
/**
* Text field with attached confirmation buttons.
*
* @param {real} _width Field width.
* @param {real} _height Field height.
* @param {string} _prompt Text field prompt.
* @param {function} _acceptaction Code to run when accept is pressed.
* @param {function} _cancelaction Code to run when cancel is pressed.
*/
function TextField(_width, _height, _prompt, _acceptaction, _cancelaction) : Component(_width, _height) constructor {
	prompt = _prompt;
	accept = _acceptaction;
	cancel = _cancelaction;
	stored_text = "";
	enter_button = new Button(56, 40, "menu_enter", accept);
	cancel_button = new Button(56, 40, "menu_cancel", cancel);
	enter_button.default_color = c_green;
	enter_button.over_color = c_lime;
	cancel_button.default_color = c_maroon;
	cancel_button.over_color = c_red;
	input_position = 0;
	input_position_offset = 0;
	
	function draw(_x, _y) {
		// Prepare drawing configuration.
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _field_input_surface = surface_create(492, 20);
	
		// Draw field
		draw_rectangle_color(_x - 250, _y - 50, _x + 250, _y + 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false); // Back
		draw_rectangle_color(_x - 246, _y - 22, _x + 246, _y + 2, c_black, c_black, c_black, c_black, false); // Field
		draw_reset();
		draw_text(_x - 246, _y - 46, get_text(prompt)); // Prompt
	
		// Draw input field
		surface_set_target(_field_input_surface);
		var _f = string_copy(stored_text, 0, input_position);
		// Push out beginning of string if text gets too big.
		var _tx = clamp(0 - string_width(_f) + 480, -1000, 0);
		draw_text(_tx, 0, string(stored_text));
		draw_text(_tx + string_width(_f) - 1, 0, global.field_cursor);
		surface_reset_target();
		draw_surface(_field_input_surface, _x - 242, _y - 22);
	
		// Draw and handle buttons
		enter_button.draw(_x - 218, _y + 26);
		cancel_button.draw(_x + 218, _y + 26);
	
		// Handle text input.
		if (keyboard_lastkey != vk_nokey) {
			if (is_in_range(ord(keyboard_lastchar), 32, 255) && string_length(stored_text) < 32) {
				stored_text = string_insert(keyboard_lastchar, stored_text, input_position + 1);
			}
			else {
				switch (keyboard_lastkey) {
					case (vk_backspace): {
						if (input_position != 0) {
							stored_text = string_delete(stored_text, input_position, 1);
						}
					} break;
					case (vk_left): {
						if !(-input_position_offset >= string_length(stored_text)) {
							input_position_offset--;
						}
					} break;
					case (vk_right): {
						if (input_position_offset < 0) {
							input_position_offset++;
						}
					} break;
				}
			}
			keyboard_lastchar = "";
			keyboard_lastkey = vk_nokey;
			input_position = string_length(stored_text) + input_position_offset;
		}
	
		// Cleanup
		surface_free(_field_input_surface);
	}
}

/**
* Ask the player to confirm something (simply closes without doing anything if cancel is pressed).
*
* @param {string} _prompt Prompt.
* @param {function} _acceptaction Code to run when accept is pressed.
*/
function ConfirmDialogue(_prompt, _acceptaction) constructor {
	prompt = _prompt;
	accept = _acceptaction;
	confirm_button = new Button(56, 40, "menu_yes", function() {
		method_call(accept);
		global.confirm_dialogue = undefined;
	});
	cancel_button = new Button(56, 40, "menu_no", function() {
		global.confirm_dialogue = undefined;
	});
	confirm_button.default_color = c_green;
	confirm_button.over_color = c_lime;
	cancel_button.default_color = c_maroon;
	cancel_button.over_color = c_red;
	
	function draw(_x, _y) {
		// Prepare drawing configuration.
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _width = max(string_width(get_text(prompt)), 136);
	
		// Draw field
		draw_rectangle_color(_x - _width / 2, _y - 50, _x + _width / 2, _y + 50, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false); // Back
		draw_reset();
		draw_text(_x - _width / 2, _y - 46, get_text(prompt)); // Prompt

		// Draw and handle buttons
		confirm_button.draw(_x - (_width / 2)  + 36, _y + 26);
		cancel_button.draw(_x + (_width / 2) - 36, _y + 26);
		
		// Escape input
		if (keyboard_check_pressed(vk_escape)) {
			global.confirm_dialogue = undefined;
		}
	}
}

/**
* Button variant for handling keybinds.
*
* @param {real} _width Width of bind button.
* @param {real} _height Height of bind button.
* @param {string} _text Label of bind button.
* @param {string} _bind Which bind is tied to this button.
* @param {real} _default Default keybind configuration.
*/
function BindButton(_width, _height, _text, _bind, _default) : Component(_width, _height) constructor {
	defaultbind = _default;
	text = _text;
	bind = _bind;
	selected = false;
	static other_selected = false;
	
	function draw(_x, _y) {
		// Prepare drawing configuration.
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _xdist = width / 2;
		var _ydist = height / 2;
	
		// Draw button and handle mouse actions.
		var _bind_text = vk_tostring(variable_struct_get(global.settings, bind));
		if (mouse_is_over(_x - _xdist, _y - _ydist, _x + _xdist, _y + _ydist, true) || selected) {
			draw_rectangle_color(_x - _xdist, _y - _ydist, _x + _xdist, _y + _ydist, c_ltgray, c_ltgray, c_ltgray, c_ltgray, false);
			// Toggle selection
			if (mouse_check_button_pressed(1) && !BindButton.other_selected) {
				audio_play_sound(snd_uisel, 1, false);
				selected = true;
				BindButton.other_selected = true;
				keyboard_lastkey = vk_nokey;
				_bind_text = global.field_cursor;
			}
			
			// Get keybind input
			if (selected && keyboard_lastkey != vk_nokey) {
				variable_struct_set(global.settings, bind, keyboard_lastkey);
				selected = false;
				BindButton.other_selected = false;
				_bind_text = vk_tostring(variable_struct_get(global.settings, bind));
			}
		}
		else {
			draw_rectangle_color(_x - _xdist, _y - _ydist, _x + _xdist, _y + _ydist, c_gray, c_gray, c_gray, c_gray, false);
		}
		draw_text(_x, _y, get_text(text) + _bind_text);
	
		// Reset drawing configuration.
		draw_reset();
	}
}
/**
* Draw a surface section with a scroll bar.
*
* @param {real} _width Width of surface.
* @param {real} _height TOTAL height of surface.
* @param {real} _maxheight How much of this surface can be seen at once.
* @param {function} _todraw What to draw on the surface.
*/
function ScrollableSurface(_width, _height, _maxheight, _todraw) : Component(_width, _height) constructor {
	panel_height = _maxheight;
	ceiling = 0;
	todraw = _todraw;
	scroll_color = c_gray;
	scroll_mouse_selected = false;
	
	function draw(_x, _y) {		
		// Draw contents
		var _surface = surface_create(width, height);
		surface_set_target(_surface);
		todraw();
		surface_reset_target();
		draw_surface_part(_surface, 0, ceiling, width, panel_height, _x, _y);
		surface_free(_surface);
		
		// Draw scroll bar
		if (height > panel_height) {
			var _barheight = (panel_height / height) * panel_height; // Size of scroll bar.
			var _barpos = (ceiling / height) * panel_height; // Position of scroll bar
			var _sx = _x + width - 10; // Left side of scroll bar
			
			// Handle input
			// Scrolling up
			if (mouse_wheel_up() && ceiling > 0) {
				ceiling -= min(50, ceiling);
			}
			// Scrolling down
			if (mouse_wheel_down() && ceiling + panel_height < height) {
				ceiling += min(50, height - ceiling + panel_height);
			}
			// Middle Click
			if (mouse_check_button(3)) {
				ceiling = 0;
			}
			// Mouse dragging
			if (mouse_is_over(_sx, _y, _sx + 10, _y + panel_height, true) || scroll_mouse_selected) {
				scroll_color = c_ltgray;
				if (mouse_check_button(1)) {
					scroll_mouse_selected = true;
					ceiling = (clamp(window_mouse_get_y() - _y - _barheight / 2, 0, panel_height - _barheight) / panel_height) * height;
				}
				else {
					scroll_mouse_selected = false;
				}
			}
			else {
				scroll_color = c_gray;
			}	
			// Draw scroll bar
			draw_roundrect_color(_sx, _y + _barpos, _sx + 10, _y + _barpos + _barheight, scroll_color, scroll_color, false);
		}
	}
}