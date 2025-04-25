/// @description Setup
event_inherited();
fuel_input = new Inventory(1, "fuel_input" ,INVTYPES.INPUT, [1, 5, 6, 7, 8, 9]); // Fuel Input Inventory
burntime = 0; // Burn Timer
active = false; // Whether firepit is burning.
returns = [[new ItemStack(2, 1), 1]]; // What firepit returns when broken.
inventories = [fuel_input]; // Inventories in firepit.

// Establish Info
establish_info = function(_socket) {
	entity_establish_info(2, [active], _socket)
}

// Inventory Info
interface_establish_info = function(_socket) {
	entity_establish_info(3, [burntime], _socket)
	entity_establish_info(0, fuel_input.contents, _socket);
}