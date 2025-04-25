/**
 * Check if value is within specified range
 *
 * @param {real} _value Value to check.
 * @param {real} _min Minimum of range (inclusive).
 * @param {real} _max Maimum of range (inclusive).
 * @returns {bool} Whether value was in range.
 */
function is_in_range(_value, _min, _max) {
	return (_value >= _min && _value <= _max)
}
	
/**
 * Reset draw alignment, color, and alpha to defaults.
 */
function draw_reset() {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
	
/**
 *  Perform a "dice roll" and return true if it lands.
 *
 * @param {real} _chance Chance of roll landing, from 0 to 1.
 * @returns {bool} Whether roll landed.
 */
function dice_roll(_chance) {
	// Get a random decimal from 0 to 1, and return true if that random number is not greater than the chance.
	return random_range(0, 1) <= _chance;
}
	
/**
 * Check if mouse is over an object.
 *
 * @param {id.instance<global>} [_instance] Instance to check for.
 * @returns {bool} Whether mouse was over object.
 */
function mouse_collision(_instance = self) {
	return place_meeting(mouse_x, mouse_y, _instance);
}

/**
 * Load a struct from a JSON file.
 *
 * @param {string} _file JSON file to load.
 * @returns {struct} Struct containing JSON data.
 */
function load_json(_file) {
	// Load the JSON text from the file, read it, and convert it to a struct.
	return json_parse(buffer_read(buffer_load(_file), buffer_text));
}

/**
 * Save a struct to a JSON file.
 *
 * @param {struct} _struct Struct to save to file.
 * @param {string} _file JSON file to save to.
 */
function save_json(_struct, _file) {
	// Create a buffer and write struct to it.
	var _tosave = json_stringify(_struct);
	var _savebuffer = buffer_create(string_byte_length(_tosave) + 1, buffer_fixed, 1);
	buffer_write(_savebuffer, buffer_string, _tosave);
	
	// Save buffer to file.
	buffer_save(_savebuffer, _file);
	
	// Free buffer from memory.
	buffer_delete(_savebuffer);
}

/**
 * Generates an integer from a string.
 *
 * @param {string} _seed String to use for generation.
 * @returns {real} Generated number.
 */
function generate_number(_seed) {
	var _out = "";
	// Generates a numerical string by getting the ASCII/UTF values of every character and concatenating them.
	for (var _i = 0; _i < string_length(_seed); _i++) {
		_out += string(ord(string_char_at(_seed, _i)));
	}
	
	// As reals are floating points, this should hopefully be able to handle long inputs.
	return real(_out);
}
	
/**
 * Return the current date in MM/DD/YYYY format.
 *
 * @returns {string} Current date formatted in MM/DD/YYYY.
 */
function get_date_mmdd() {
	return string("%d/%d/%d", current_month, current_day, current_year);
}

/**
* Ensure that a given file name is valid.
*
* @param {string} _name Input name.
* @param {string} _fname Output name.
*/
function file_name_verify(_name) {
	// Remove any abnormal characters from the string.
	_name = string_trim(_name);
	
	// Seperate words and filter them, then reconcatenate them.
	var _words = string_split(_name, " ");
	var _out = "";
	for (var _i = 0; _i < array_length(_words); _i++) {
		_words[_i] = string_lettersdigits(_words[_i]);
		_out += string("{0} ", _words[_i]);
	}

	
	// Remove any spaces at the beginning or end.
	_out = string_trim(_out);
	
	// Return the filtered string.
	return _out;
}

/**
 * Convert a virtual key into a string.
 *
 * @param {real} _vk Virtual key to convert.
 * @returns {string} Output string.
 */
function vk_tostring(_vk) {
	if(_vk > 48 && _vk < 91 ) { 
		// If this is a key or number, return that.
		return chr(_vk); 
	}
	switch(_vk) {
		// Otherwise, compare it to this table.
	    case -1: return "No Key";
	    case 8: return "Backspace";
	    case 9: return "Tab";
	    case 13: return "Enter";
	    case 16: return "Shift";
	    case 17: return "Ctrl";
	    case 18: return "Alt";
	    case 19: return "Pause/Break";
	    case 20: return "CAPS";
	    case 27: return "Esc";
		case 32: return "Space";
	    case 33: return "Page Up";
	    case 34: return "Page Down";
	    case 35: return "End";
	    case 36: return "Home";
	    case 37: return "Left Arrow";
	    case 38: return "Up Arrow";
	    case 39: return "Right Arrow";
	    case 40: return "Down Arrow";
	    case 45: return "Insert";
	    case 46: return "Delete";
	    case 96: return "Numpad 0";
	    case 97: return "Numpad 1";
	    case 98: return "Numpad 2";
	    case 99: return "Numpad 3";
	    case 100: return "Numpad 4";
	    case 101: return "Numpad 5";
	    case 102: return "Numpad 6";
	    case 103: return "Numpad 7";
	    case 104: return "Numpad 8";
	    case 105: return "Numpad 9";
	    case 106: return "Numpad *";
	    case 107: return "Numpad +";
	    case 109: return "Numpad -";
	    case 110: return "Numpad .";
	    case 111: return "Numpad /";
	    case 112: return "F1";
	    case 113: return "F2";
	    case 114: return "F3";
	    case 115: return "F4";
	    case 116: return "F5";
	    case 117: return "F6";
	    case 118: return "F7";
	    case 119: return "F8";
	    case 120: return "F9";
	    case 121: return "F10";
	    case 122: return "F11";
	    case 123: return "F12";
	    case 144: return "Num Lock";
	    case 145: return "Scroll Lock";
	    case 186: return ";";
	    case 187: return "=";
	    case 188: return ",";
	    case 189: return "-";
	    case 190: return ".";
	    case 191: return "\\";
	    case 192: return "`";
	    case 219: return "/";
	    case 220: return "[";
	    case 221: return "]";
	    case 222: return "'";
		default: return "Unknown";
	}
}