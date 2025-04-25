/// @description Save Game
// Delayed by one frame after quitting so we can get instance information.
// If we are not connected to a remote server, save the game.
if (obj_control.game_type != 3) {
	save_game();
}
	
// Return to the main menu.
room_goto(rm_menu);

// If we are not in singleplayer, destroy the client socket.
if (obj_control.game_type != 0) {
	network_destroy(obj_client.client_socket);
}
// If we are hosting, destroy the server socket.
if (obj_control.game_type == 1) {
	network_destroy(obj_server.server_socket);
}