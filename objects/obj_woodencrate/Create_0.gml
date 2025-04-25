/// @description Setup
event_inherited();
// Inventory
contents = new Inventory(30, "contents", INVTYPES.STORAGE);
inventories = [contents];
returns = [[new ItemStack(7, 1), 1]]; // Return self when broken.

// Inventory Info
interface_establish_info = function(_socket) {
	entity_establish_info(0, contents.contents, _socket);
}