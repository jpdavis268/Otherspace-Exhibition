
/**
 * Prints a message in client chat (does not send to server).
 *
 * @param {string} _print String to print to chat.
 */
function chat_print(_print) {
	with (obj_chathandler) {
		// Increment chat history.
		for (var _i = array_length(chat_text_) - 1; _i >= 0; _i--) {
			chat_text_[_i + 1] = chat_text_[_i];
		}
		// Increment recent message log.
		for (var _i = array_length(chat_recent_) - 1; _i >= 0; _i--) {
			chat_recent_[_i + 1] = chat_recent_[_i];
		}
		
		// Send message
		chat_recent_[1] = 3600;
		var _text = string(_print);
		var _b = string_width(_text) / 780;
		// If the message contains a long string of letters without a space, insert one so the line can break.
		for (var _i = 1; _i <= _b; _i++) {
			if (string_last_pos(" ", _text) < string_length(_text) - 10) {
				_text = string_insert(" ", _text, string_length(_text) / _b * _i);
			}
		}
		chat_text_[0] = _text;
	}
}
	
/**
*  Send Chat Message to Server (and Client)
*
*  @param {string} _message Message to send.
*/
function chat_send(_message) {
	client_send_data([1, _message]);
}

/**
 * Handle a console command sent by a client.
 *
 * @param {string} _input Command sent by client.
 * @param {Id.Socket} _socket Client socket who sent command.
 */
function process_console_command(_input, _socket) {
	// Prepare variables
	var _command = "";
	var _arg;
	_arg[0] = "";
	var _argcount = 0;
	_input += " ";
	var _word = "";
	
	// Parse input.
	for (var _i = 0; _i < string_length(_input); _i++) {
		// Get next word
		var _nchar = string_char_at(_input, _i + 1);
		if (_nchar != " ") {
			_word += _nchar;
		}
		else {
			// If we have a full word, process it,
			if (_command = "") {
				// First word (command).
				_command = asset_get_index(string_letters(_word));
				if (script_exists(_command)) {
					// Valid command
					_command = string_letters(_word);
					_word = "";
					continue;
				}
				else {
					// Command not recognized
					server_send_data([2, _input], _socket);
					server_send_data([2, "Unknown Command."], _socket);
					_command = "";
					_word = "";
					break;
				}
			}
			else {
				// Additional word (argument).
				_arg[_argcount] = _word;
				_argcount++;
				_word = "";
			}
		}
	}
	if (script_exists(asset_get_index(_command)) && array_contains(global.console_commands, _command)) {
		// Function being called exists and is on the list of console commands.
		// (If this check were not in place, the console could be used to execute *any* function defined within a script file,
		// most of which would promptly crash the game or cause severe issues if executed randomly.)
		server_send_data([2, _input], _socket)
		// The function below works fine, don't know why there is an error message.
		var _return = script_execute_ext(asset_get_index(_command), _arg);
		// If the command returned something, send it back to the client that ran the command.
		if (_return != 0) {
			server_send_data([2, _return], _socket);
		}
	}
	else if ((script_exists(asset_get_index(_command)) && !array_contains(global.console_commands, _command))) {
		// Function being called exists, but is not intended to be used as a console command.
		server_send_data([2, _input], _socket);
		server_send_data([2, "Unknown Command."], _socket);
		_command = "";
		_word = "";
	}
}