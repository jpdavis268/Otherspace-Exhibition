/// @description Setup
// Player Input Variables
floor_mode = false; // Build Layer
debug_enabled = false; // Whether debug mode is enabled.
show_chunks = false; // Whether the chunk grid is enabled.
camera_zoom = 1; // Camera zoom.
move_last = [0, 0]; // Last movement order.
build_tm = undefined; // Which tilemap we are building on.
has_sent_build_cancel_order = false; // Whether we have told the server that the player stopped building.
has_sent_break_cancel_order = false; // Whether we have told the server that the player stopped mining.
current_hover = [0, -1]; // What we are currently hovering over in an inventory.
hover_slot_last = -1; // The last slot we hovered over.
current_recipe = -1; // Currently selected recipe.
last_recipe = -1; // Last selected recipe.
current_sb_item_sel = -1; // Current sandbox item selection.
current_sb_tile_sel = [ts_ground, -1]; // Current sandbox tile selection.
recipe_progress = 0; // Crafting progress.
has_sent_craft_cancel_order = false; // Whether we have told the server the player stopped crafting.
has_sent_sb_build_cancel_order = false; // Whether we have told the server the player stopped using a brush.
sb_build_brushsize = 1; // Sandbox brush size.