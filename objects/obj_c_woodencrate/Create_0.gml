/// @description Setup
event_inherited();
has_gui = true;
contents = new DisplayInventory(30, "contents");
my_gui = new GUI(0, 0, 426, 304, function () { // GUI
	draw_text(4, 4, get_text("woodencrate_gui_header")); // Header
	inv_mapping = draw_inventory_matrix(4, 24, contents, 3); // Crate  Inventory
	inventory_matrix_mouse_map(contents, inv_mapping); // Crate Inventory Mouse Mapping
	draw_text(4, 156, get_text("player_inventory")); // Inventory Header
	inv_mapping2 = draw_inventory_matrix(4, 176, obj_playerchar.player_inventory, 3); // Player Inventory
	inventory_matrix_mouse_map(obj_playerchar.player_inventory, inv_mapping2); // Player Inventory Mouse Mapping
});

// Update Handler
update_handler = function (_protocol, _data) {
	switch (_protocol) {
		case 0: { // Inventory Loading
			contents.contents = _data;
		} break;
		case 1: { // Inventory Update
			var _inv = variable_instance_get(self, _data[2]);
			_inv.contents[_data[0]] = _data[1];
		} break;
	}
}