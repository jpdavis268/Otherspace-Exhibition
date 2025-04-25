/**
 * Check to see if two itemstacks are the same item.
 *
 * @param {struct} _itemstack1 First itemstack to check.
 * @param {struct} _itemstack2 Second itemstack to check.
 * @returns {bool} Whether items were the same.
 */
function same_item(_itemstack1, _itemstack2) {
	var _stack1vars = struct_get_names(_itemstack1);
	var _stack2vars = struct_get_names(_itemstack2);
	
	// Remove Stack Size Variable
	array_delete(_stack1vars, array_get_index(_stack1vars, "stacksize"), 1);
	array_delete(_stack2vars, array_get_index(_stack2vars, "stacksize"), 1);
	
	// Retreive Array Values
	var _stack1values = [];
	var _stack2values = [];
	
	for (var _i = 0; _i <= array_length(_stack1vars) - 1; _i++) {
		_stack1values[_i] = struct_get(_itemstack1, _stack1vars[_i]);
	}
	
	for (var _i = 0; _i <= array_length(_stack2vars) - 1; _i++) {
		_stack2values[_i] = struct_get(_itemstack2, _stack2vars[_i]);
	}

	// Test for Equivalence
	return (array_equals(_stack1values, _stack2values) && (_itemstack1.stacksize > 0 && _itemstack2.stacksize > 0));
}

/**
 * Copy an existing itemstack. 
 *
 * @param {struct} _itemstack Itemstack to copy.
 * @returns {struct} New itemstack.
 */
function itemstack_copy(_itemstack) {
	return new ItemStack(_itemstack.item_id, _itemstack.stacksize);
}
	
/**
 * Spawn dropped items.
 *
 * @param {struct} _itemstack Itemstack to drop.
 * @param {real} _x x-coordinate to drop items.
 * @param {real} _y y-coordinate to drop items.
 */
function drop_items(_itemstack, _x, _y) {
	// Determine how large stack can be, and how many stacks we will have to drop.
	var _maxsize = global.item_id[_itemstack.item_id].maxsize;
	var _std = ceil(_itemstack.stacksize / _maxsize)
	var _items = _itemstack.stacksize;
	// Create itemstacks and fill them until we run out of items.
	for (var _i = 1; _i <= _std && _items > 0; _i++) {
		var _j = instance_create_layer(irandom_range(_x - 16, _x + 15), irandom_range(_y - 16, _y + 15), "Server", obj_itemstack);
		_j.contents.contents[0] = itemstack_copy(_itemstack);
		_j.contents.contents[0].stacksize = min(_items, _maxsize);
		_items -= min(_items, _maxsize);
	}
}

/**
 * Try to add items to an inventory.
 *
 * @param {any*} _inventory Inventory to add to.
 * @param {struct} _itemstack Itemstack to try to add.
 * @param {bool} [_istransfer] Whether this is part of a transfer.
 * @param {real} [_dropx] x-coordinate to drop items if we cannot input them all.
 * @param {real} [_dropy] y-coordinate to drop items if we cannot input them all.
 * @returns {real} How many items we could not put in the inventory.
 */
function inventory_add(_inventory, _itemstack, _istransfer = false, _dropx = self.x, _dropy = self.y) {
	// Determine how many seperate stacks of this item we are adding.
	var _maxsize = global.item_id[_itemstack.item_id].maxsize
	var _sta = ceil(_itemstack.stacksize / _maxsize);
	var _items = _itemstack.stacksize;
	var _remainder = 0;
	// For every stack to add, try to find a place to put it.
	for (var _i = 1; _i <= _sta; _i++) {
		// Condition 1: Existing equivalent stack with space to spare.
		for (var _j = 0; _j < array_length(_inventory.contents) && _items > 0; _j++) {
			if (same_item(_inventory.contents[_j], _itemstack)) {
				// Try to add as much as we can to the existing stack.
				var _v = min(_items, (_maxsize - _inventory.contents[_j].stacksize));
				_inventory.contents[_j].stacksize += _v; 
				_items -=  _v;
				// If anything changed, send an inventory update.
				if (_v > 0) {
					with (_inventory.host) {
						send_inventory_update(_j, _inventory);
					}
				}
			}
		}
		// Condition 2: No existing equivalent stack, but inventory has empty space.
		// We don't want this to run until every slot has been checked in Condition 1,
		// hence why it is a sepeate loop.
		for (var _j = 0; _j < array_length(_inventory.contents) && _items > 0; _j++) {
			if (_inventory.contents[_j].stacksize <= 0) {
				// Add the lesser of the total amount of items or the maximum allowed size to the empty space.
				_inventory.contents[_j] = itemstack_copy(_itemstack);
				var _v = min(_items, _maxsize)
				_inventory.contents[_j].stacksize = _v;
				_items -= _v;
				// If anything changed, send update.
				if (_v > 0) {
					with (_inventory.host) {
						send_inventory_update(_j, _inventory);
					}
				}
			}
		}
		// Condition 3: No space in inventory.
		if (_items > 0) {
			// If this was not transferred from another inventory, drop the items on the ground.
			if (!_istransfer) {
				var _t = _itemstack
				_t.stacksize = _items;
				drop_items(_t, _dropx, _dropy);
				_items = 0;
			}
			// Otherwise, return the remaining amount of items.
			else {
				_remainder = _items;
			}
		}
	}
	return _remainder;
}

/**
 * Remove items from an inventory.
 *
 * @param {struct} _inventory Inventory to remove items from.
 * @param {struct} _itemstack Items to try to remove.
 */
function inventory_subtract(_inventory, _itemstack) {
	var _items = _itemstack.stacksize;
	// Index through inventory backwards, taking out items until we reach our quota.
	for (var _i = array_length(_inventory.contents) - 1; _i >= 0 && _items > 0; _i--) {
		// If we find the items we are looking for, subtract the lesser of the remaining quota or the size of the stack.
		if (same_item(_itemstack, _inventory.contents[_i]) && _inventory.contents[_i].stacksize > 0) {
			var _v = min(_items, _inventory.contents[_i].stacksize);
			_items -= _v;
			_inventory.contents[_i].stacksize -= _v;
			// If something changed, send an inventory update.
			if (_v > 0) {
				with (_inventory.host) {
					send_inventory_update(_i, _inventory);
				}
			}
		}
	}
}

/**
 * Attempt to transfer items between two inventories.
 *
 * @param {any} _frominv Inventory to move items from.
 * @param {struct} _toinv Inventory to put items in.
 * @param {struct} _itemstack Items to try and move.
 */
function inventory_transfer(_frominv, _toinv, _itemstack) {
	// Add contents to destination.
	var _r = inventory_add(_toinv, _itemstack, true);
	// Subtract the number of remaning items from the itemstack.
	_itemstack.stacksize -= _r;
	// Subtract the itemstack (less what didn't get added to the other inventory) from the source inventory.
	inventory_subtract(_frominv, _itemstack);
}

/**
 * Attempt to transfer items between two inventories from a specific slot.
 *
 * @param {struct} _frominv Inventory to move items from.
 * @param {real} _fromslot Slot to transfer from.
 * @param {struct} _toinv Inventory to put items in.
 * @param {struct} _itemstack Items to try and move.
 */
function inventory_transfer_from_slot(_frominv, _fromslot, _toinv, _itemstack) {
	// Add item from inventory and subtract the amount added from the slot.
	var _r = inventory_add(_toinv, _itemstack, true)
	_itemstack.stacksize -= _r;
	_frominv.contents[_fromslot].stacksize -= _itemstack.stacksize;
	
	// Send inventory update.
	with (_frominv.host) {
		send_inventory_update(_fromslot, _frominv);
	}
}

/**
 * Attempt to transfer items between two slots in two inventories.
 *
 * @param {struct} _frominv Inventory to move items from.
 * @param {real} _fromslot Slot to transfer from.
 * @param {struct} _toinv Inventory to put items in.
  * @param {real} _toslot Slot to transfer to.
 * @param {real} _itemcount Number of items to try to transfer.
 */
function inventory_slot_transfer(_frominv, _fromslot, _toinv, _toslot, _itemcount) {
	// How many to transfer? (everything if no amount is specified)
	var _num = _itemcount == -1 ? _frominv.contents[_fromslot].stacksize : _itemcount;

	// If _toslot is -1, run the normal from slot transfer method.
	if (_toslot == -1) {
		var _a = itemstack_copy(_frominv.contents[_fromslot]);
		_a.stacksize = _num;
		inventory_transfer_from_slot(_frominv, _fromslot, _toinv, _a);
		exit;
	}
	
	// Run percise slot transfer otherwise.
	var _a = _frominv.contents[_fromslot];
	var _b = _toinv.contents[_toslot];
	var _s = global.item_id[_b.item_id].maxsize - _b.stacksize;
	var _v = min(_num, min(_a.stacksize, _s));
	// If the two items are the same type, just move as many as we can.
	if (same_item(_a, _b)) {
		_frominv.contents[_fromslot].stacksize -= _v;
		_toinv.contents[_toslot].stacksize += _v;
	}
	// If the destination slot is empty, move the item over.
	else if (_b.stacksize <= 0) {
		var _new = itemstack_copy(_a);
		_new.stacksize = _v;
		_frominv.contents[_fromslot].stacksize -= _v;
		_toinv.contents[_toslot] = _new;
	}
	// If none of the above are true, just swap the slots.
	else {
		_frominv.contents[_fromslot] = _b;
		_toinv.contents[_toslot] = _a;
	}
	
	// The inventory update for the source inventory only actually routes properly if called through this function,
	// likely due to some quirk with the engine.
	var _proxy = function(_slot, _inv) {
		send_inventory_update(_slot, _inv);
	}
	
	with (_toinv.host) {
		send_inventory_update(_toslot, _toinv);
	}
	with (_frominv.host) {
		method_call(_proxy, [_fromslot, _frominv]);
	}
}
	
/**
 * Inform clients interfacing with an entity of an inventory update.
 *
 * @param {real} _slot Slot updated.
 * @param {struct} _inventory Inventory updated.
 */
function send_inventory_update(_slot, _inventory) {
	var _itemstack = _inventory.contents[_slot];
	var _name = _inventory.name;
	entity_send_interface_update(1, [_slot, _itemstack, _name]);
}

/**
 * Check if an inventory has specific items.
 *
 * @param {struct} _inventory Inventory to check.
 * @param {array} _items List of items.
 * @returns {bool} Whether items were found.
 */
function inventory_has_items(_inventory, _items) {
	var _num = array_length(_items);
	// Check each item against the contents of the inventory.
	for (var _i = 0; _i < _num; _i++) {
		var _r = _items[_i].stacksize;
		// Index through inventory, subtracting the size of any found stacks from the remainder.
		for (var _j = 0; _j < array_length(_inventory.contents) && _r > 0; _j++) {
			if (same_item(_inventory.contents[_j], _items[_i])) {
				_r -= _inventory.contents[_j].stacksize;
			}
		}
		// If we reached the end of the inventory and still have a remainder, return false.
		if (_r > 0) {
			return false;
		}	
	}
	return true;
}
