/// @description Drops
event_inherited();
returns = [[new ItemStack(9, 1), 1]];
age = 0;
growtime = 172800;

// Establish Info
establish_info = function(_socket) {
	entity_establish_info(0, [floor(age / growtime * 4)], _socket);
}