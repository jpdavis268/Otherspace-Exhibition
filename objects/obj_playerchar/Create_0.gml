/// @description Player Inventory and GUI
// Audio Setup
audio_listener_orientation(0, 0, 1, 0, -1, 0);
footstep_sound = undefined;
step_pattern = false;
// Built in coordinate tracking breaks in multiplayer, so this is needed.
xprev = x;
yprev = y;

// GUI Variables
sb_menu = 0; // Current sandbox menu.
// Sandbox toggle for crafting/spawning mode.
toggle_sb_inv_button = new Button(64, 64, "", function() {
	sb_menu = !sb_menu;
	toggle_sb_inv_button.hover_text = sb_menu ? "inventory_crafting_header" : "inventory_sb_item_header";
}, "inventory_sb_item_header");

// Player Inventory GUI Setup
player_inventory = new DisplayInventory(30, "player_inventory"); // Player inventory
held_item = new DisplayInventory(1, "held_item"); // Currently held item.
my_gui = new GUI(0, 0, 426, 304, function() { // Inventory GUI
	var _darkergray = make_color_rgb(48, 48, 48);
	draw_rectangle_color(0, 0, 426, 152, _darkergray, _darkergray, _darkergray, _darkergray, false); // Background
	switch (sb_menu) {
		case 0: { // Draw Crafting Menu
			draw_text(4, 4, get_text("inventory_crafting_header"));
			recipe_mapping = draw_crafting_matrix(4, 24, 30, 3);
			obj_inputhandler.current_recipe = crafting_matrix_mouse_map(recipe_mapping);
		} break;
		case 1: { // Draw Sandbox Spawning Menu
			draw_text(4, 4, get_text("inventory_sb_item_header"));
			sb_item_mapping = draw_sandbox_item_matrix(4, 24, 30, 3);
			obj_inputhandler.current_sb_item_sel = sandbox_item_mouse_map(sb_item_mapping);
		} break;
	}
	draw_text(4, 156, get_text("player_inventory")); // Inventory Header
	inv_mapping = draw_inventory_matrix(4, 176, obj_playerchar.player_inventory, 3); // Draw Inventory
	inventory_matrix_mouse_map(player_inventory, inv_mapping); // Mouse Mapping
	if (obj_gamehandler.player_gm) { // Draw toggle button in sandbox mode.
		var _t = surface_get_target();
		surface_reset_target();
		toggle_sb_inv_button.draw(display_get_gui_width() / 2 + 245, display_get_gui_height() / 2 - 120, window_get_height(), true);
		draw_sprite(spr_sb_item_toggle, sb_menu, display_get_gui_width() / 2 + 245, display_get_gui_height() / 2 - 120);
		surface_set_target(_t);
	}
	else {
		// Enforce survival GUI
		sb_menu = 0;
	}
});
	
// Update Handler
update_handler = function (_protocol, _data) {
	switch (_protocol) {
		case 0: { // Inventory Loading
			player_inventory.contents = _data;
		} break;
		case 1: { // Inventory Update
			var _inv = variable_instance_get(self, _data[2]);
			_inv.contents[_data[0]] = _data[1];
		} break;
	}
}