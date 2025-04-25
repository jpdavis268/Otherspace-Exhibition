/// @description Initialization
event_inherited();
returns = [[new ItemStack(8, 1), 1]];
my_text = "";

// Establish Info
establish_info = function(_socket) {
	entity_establish_info(0, [my_text], _socket);
}