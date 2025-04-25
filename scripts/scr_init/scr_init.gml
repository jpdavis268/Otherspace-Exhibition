/// @description Initialize game based on intended setup method.

function game_init() {
	// Server infrastructure setup
	var _a = function() {
		layer_create(0, "Server");	
		instance_create_layer(0, 0, "Server", obj_manager);
		instance_create_layer(0, 0, "Server", obj_server);
		load_game();
		};
	
	// Client infrastructure setup
	var _b = function() {
		// Handlers Layer
		layer_create(0, "Handlers");
		instance_create_layer(0, 0, "Handlers", obj_chathandler);
		instance_create_layer(0, 0, "Handlers", obj_gamehandler);
		instance_create_layer(0, 0, "Handlers", obj_inputhandler);
		instance_create_layer(0, 0, "Handlers", obj_guihandler);
		instance_create_layer(0, 0, "Handlers", obj_lighthandler);
		instance_create_layer(0, 0, "Handlers", obj_pausehandler);
		instance_create_layer(0, 0, "Handlers", obj_selector);
		instance_create_layer(0, 0, "Handlers", obj_client);
		// Instances Layer
		layer_create(0, "Instances");
		// Tile Layers
		layer_create(9700, "Walls");
		layer_create(9800, "Floor");
		layer_create(9900, "Ground");
		// Tilegrid Layer
		layer_create(-10000, "Tilegrid");
		var _a = layer_background_create("Tilegrid", spr_tilegrid);
		layer_background_htiled(_a, true);
		layer_background_vtiled(_a, true);
		layer_set_visible("Tilegrid", false);
		};
	
	// Call setup methods based on game type
	switch (obj_control.game_type) {
		case 0:
		case 1: { // Singleplayer or hybrid multiplayer host
			method_call(_a, []);
			method_call(_b, []);
			} break;
		case 2: { // Dedicated server
			method_call(_a, []);
			} break;
		case 3: { // Multiplayer client
			method_call(_b, []);
			} break;
		}
}