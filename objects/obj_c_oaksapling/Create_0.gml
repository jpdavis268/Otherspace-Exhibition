// Inherit the parent event
event_inherited();
image_xscale = (floor(x / 32) % 2 == floor(y / 32) % 2) ? 1 : -1;

// Update Handler
update_handler = function(_protocol, _data) {
	switch (_protocol) {
		case 0: { // Update Growth Stage
			image_index = _data[0];
		} break;
	}
}