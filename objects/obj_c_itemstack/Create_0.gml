/// @description Setup
event_inherited();
silent = true;
item = new DisplayInventory(1); // Contents

update_handler = function (_protocol, _data) {
	switch (_protocol) {
		case 0: { // Itemstack Establishment
			// Copy Data 
			item.contents = _data;
			} break;
		case 1: { // Contents Update
			// New Data
			item.contents[0] = _data[1];
		} break;
	}
}