/// @description Setup
event_inherited();
username = ""; // Player Username
my_client = -1; // Client Socket

// Selector Coordinates
interact_x = 0;
interact_y = 0;
prevint_x = 0;
prevint_y = 0;
sel_moved = false;

interact_in_range = false; // Whether selector is in interaction range.
last_entity_selection = ds_list_create(); // Nearby entities

// Info for clients
establish_info = function(_socket) {
	server_send_data([9, string(id), 0, username], _socket);
}

client_input = []; // Client Input Buffer

// Movement Input
move_h = 0;
move_v = 0;

player_inventory = new Inventory(30, "player_inventory", INVTYPES.STORAGE); // Player Inventory
held_item = new Inventory(1, "held_item", INVTYPES.BUFFER); // Held Item
floor_mode = false; // Build Layer
destroy_progress = 0; // Destroy Progress
ts_chunk = noone; // Tile Selector Chunk
build_tm = undefined; // Build Tilemap
build_input = false; // Whether we have orders to build.
break_input = false; // Whether we have orders to mine.
current_recipe = -1; // Currently selected crafting recipe.
last_recipe = -1; // Last selected crafting recipe.
craft_progress = 0; // Crafting Progress
game_mode = global.default_gm; // Gamemode
sb_tile_layer = undefined; // Sandbox Tile Layer.
sb_tile = -1; // Sandbox Tile
sb_brush_size = 1; // Sandbox Brush Size
	
// Interface Establishment Function Template
interface_establish_info = function (_socket) {
	entity_establish_info(0, player_inventory.contents, _socket);
}