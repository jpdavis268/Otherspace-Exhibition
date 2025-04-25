/// @description Management
// If stack is empty, destroy instance.
if (contents.contents[0].stacksize = 0) {
	instance_destroy(self);
}

// Look for nearby items of the same type.
var _n = noone;
if (collision_rectangle(x - 32, y - 32, x + 31, y + 31, obj_itemstack, false, true)) {
	var _h = ds_list_create()
	collision_rectangle_list(x - 32, y - 32, x + 31, y + 31, obj_itemstack, false, true, _h, true);
	for (var _j = 0; _j <= ds_list_size(_h) - 1; _j++) {
		var _k = ds_list_find_value(_h, _j)
		if (same_item(contents.contents[0], _k.contents.contents[0]) && (contents.contents[0].stacksize < global.item_id[contents.contents[0].item_id].maxsize) && (_k.contents.contents[0].stacksize < global.item_id[_k.contents.contents[0].item_id].maxsize)) {
			_n = _k;
			break;
		}
	}
	ds_list_destroy(_h);
}

// If we are near an item of the same type, try to move towards it to combine.
var _i = get_chunk(x, y);
if (_n != noone) {
	move_and_collide(_n.x - x, _n.y - y, [obj_par_entity, _i.stm], 4, 0, 0, 2, 2);
	if (collision_rectangle(x - 16, y - 16, x + 15, y + 15, _n, false, true)) {
		inventory_transfer(contents, _n.contents, itemstack_copy(contents.contents[0]));
		with (_n) {
			entity_send_update(1, [0, contents.contents[0]]);
		}
	}
}
else {
	speed = 0;
}