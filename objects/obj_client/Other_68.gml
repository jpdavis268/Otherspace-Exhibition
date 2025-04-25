/// @description Client Data Handling
var _event = ds_map_find_value(async_load, "type");
var _id = ds_map_find_value(async_load, "id");

if (_event = network_type_data && _id == client_socket) {
	// Extract packet and process it.
	var _buffer = ds_map_find_value(async_load, "buffer");
	client_parse_data(_buffer);
}