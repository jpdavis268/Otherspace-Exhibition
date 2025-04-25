/// @description Initialization
event_inherited();
username = ""; // Username of this player.

// Handle server input.
update_handler = function (_protocol, _data) {
	switch (_protocol) {
		case 0: { // Username Initialization
			username = _data[0];
		} break;
	}
}