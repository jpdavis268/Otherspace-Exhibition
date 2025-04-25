/// @description Read Client Input
// If there is data to read, process it.
if (array_length(client_input) > 0) {
	for (var _i = 0; _i < array_length(client_input); _i++) {
		var _command = client_input[_i][0];
		var _arguments = client_input[_i][1];
		input_protocols(_command, _arguments);
	}
	client_input = [];
}