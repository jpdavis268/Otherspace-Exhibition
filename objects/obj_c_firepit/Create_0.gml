/// @description Setup
event_inherited();
range = 0.1;  // How far light shines.
flicker_dir = 1; // Which way the flicker effect is going.
has_gui = true; // Mark as having a GUI.
fuel_input = new DisplayInventory(1, "fuel_input"); // Fuel input inventory.
burntime = 0; // Track burntime.
my_gui = new GUI(0, 0, 426, 328, function () { // GUI
	draw_text(5, 5, get_text("firepit_gui_header")); // Header
	draw_healthbar(181, 137, 245, 147, (burntime / 3600) * 100, c_black, c_red, c_orange, 0, true, true); // Burn Progress Bar
	inv_mapping = draw_inventory_matrix(193, 80, fuel_input, 1); // Fuel Input Inventory
	inventory_matrix_mouse_map(fuel_input, inv_mapping); // Fuel Input Mouse Mapping
	inv_mapping2 = draw_inventory_matrix(4, 200, obj_playerchar.player_inventory, 3); // Player Inventory
	inventory_matrix_mouse_map(obj_playerchar.player_inventory, inv_mapping2); // Player Inventory Mouse Mapping
});
active = false; // Whether firepit is in use.
audio_emitter = audio_emitter_create(); // Audio emitter.
audio_emitter_falloff(audio_emitter, 256, 1024, 1); // Emitter falloff factor.
active_sound = undefined; // Store playing sound ID.

// Update Handler
update_handler = function (_protocol, _data) {
	switch (_protocol) {
		case 0: { // Inventory Loading
			fuel_input.contents = _data;
		} break;
		case 1: { // Inventory Update
			var _inv = variable_instance_get(self, _data[2]);
			_inv.contents[_data[0]] = _data[1];
		} break;
		case 2: { // State Change
			active = _data[0];
		} break;
		case 3: { // Burntime Update
			burntime = _data[0];
		} break;
	}
}