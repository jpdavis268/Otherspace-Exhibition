/// @description Setup
event_inherited();
contents = new Inventory(1, "", INVTYPES.BUFFER); // Item

// Info for clients.
establish_info = function (_socket) {
	entity_establish_info(0, contents.contents, _socket);
}