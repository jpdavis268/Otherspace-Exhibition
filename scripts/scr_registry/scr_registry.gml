// Inventory Types
enum INVTYPES {
	STORAGE,
	INPUT,
	OUTPUT,
	BUFFER,
}
	
// Item Types
enum ITEMTYPES {
	MATERIAL,
	TILE,
	TILEENTITY
}
	
// Recipe Types
enum RECIPETYPE {
	CRAFTING,
}

/**
 *  Initializes a new item.
 *
 * @param {real} [_maxsize] Maximum size of a stack of this item.
 * @param {string} [_name] Name of this item.
 * @param {real} [_itemtype] Type of this item.
 * @param {array} [_params] Special data for this item, if applicable.
 */
function Item(_maxsize = 50, _name = "", _itemtype = ITEMTYPES.MATERIAL, _params = []) constructor {
	// Item Sprites are on the ts_itemmap Tileset, Index is item_id + 1
	maxsize = _maxsize;
	name = _name;
	item_type = _itemtype;
	switch item_type {
		case ITEMTYPES.TILE: {
			params = {
				tile_id : global.tile_id[_params[0]] // Corresponding Tile ID
			}
		} break;
		case ITEMTYPES.TILEENTITY: {
			params = {
				object : _params[0], // Corresponding Tileentity
				sprite : _params[1], // Corresponding Sprite
			}
		} break;
		default: {params = {}}
	}
}

/**
 * Initialize a new tile.
 *
 * @param {string} [_name] Name of this tile.
 * @param {real} [_hardness] Tile hardness.
 * @param {array} [_returns] What this tile returns when broken.
 */
function Tile(_name = "", _hardness = 1, _returns = []) constructor {
	name = _name;
	hardness = _hardness;
	returns = _returns; // Contains a set of 3-length arrays, which contain the id to drop, how much to drop, and the drop chance from 0 to 1.
}
	
// Tile Registry
// Positions in This array correspond to tiledata. For example, since dirt is in position [1], it will correspond to the tiledata at index 1.
global.tile_id = [
	0, // Placeholder
	new Tile("tiles_dirt", 0.5, [[0, 1, 1]]), // Dirt (1), 100% chance of dropping a dirt item.
	new Tile("tiles_stone", -1, []), // Stone (2), Returns nothing for now.
	new Tile("tiles_rock_outcropping", 0.5, [[3, 1, 1], [4, 1, 0.2]]), // Rock Outcropping (3), 100% chance of dropping loose rock, 20% chance of dropping flint.
	new Tile("tiles_loose_branch", 0.5, [[1, 1, 1]]), // Loose Branch (4), 100% chance of dropping a branch.
]	
	
// Item Registry
global.item_id = [
	new Item( , "items_dirt", ITEMTYPES.TILE, [0]), // Dirt (0)
	new Item( , "items_branch", ITEMTYPES.MATERIAL), // Branch (1)
	new Item(10, "items_firepit" , ITEMTYPES.TILEENTITY, [obj_firepit, spr_firepit]), // Firepit (2)
	new Item( , "items_loose_stone", ITEMTYPES.MATERIAL), // Loose Stone (3)
	new Item( , "items_flint", ITEMTYPES.MATERIAL), // Flint (4)
	new Item( , "items_oaklog", ITEMTYPES.MATERIAL), // Oak Log (5)
	new Item( , "items_oakplanks", ITEMTYPES.MATERIAL), // Oak Planks (6)
	new Item( , "items_woodencrate", ITEMTYPES.TILEENTITY, [obj_woodencrate, spr_woodencrate]), // Wooden Crate  (7)
	new Item( , "items_sign", ITEMTYPES.TILEENTITY, [obj_sign, spr_sign]), // Sign (8)
	new Item( , "items_acorn", ITEMTYPES.TILEENTITY, [obj_oaksapling, spr_oaksapling]), // Acorn (9)
]	
	
/**
* Initializes a Crafting Recipe (don't quite know how this one will work, may split based on type eventually).
*
* @param {real} _type What type of recipe this is (which machine is needed to run it).
* @param {array<struct>} _inputs What goes into this recipe.
* @param {array<struct>} _outputs What comes out of this recipe.
* @param {real} _craftingtime Base crafting time for this recipe.
*/
function Recipe(_type, _inputs, _outputs, _craftingtime) constructor {
	type = _type;
	inputs = _inputs;
	outputs = _outputs;
	time = _craftingtime;
}
	
/**
* Creates a new stack of items (not to be confused with item, this represents the items seen in game)
*
* @param {real} [_id] Item ID.
* @param {real} [_stacksize] How many items are in this stack.
*/
function ItemStack(_id = 0, _stacksize = 0) constructor {
	item_id = _id;
	stacksize = _stacksize;
}


// Recipe Registry
global.recipe_registry = [
	new Recipe(RECIPETYPE.CRAFTING, [new ItemStack(3, 3), new ItemStack(1, 3), new ItemStack(4, 2)], [new ItemStack(2, 1)], 120), // Firepit (0)
	new Recipe(RECIPETYPE.CRAFTING, [new ItemStack(3, 3), new ItemStack(6, 3), new ItemStack(4, 2)], [new ItemStack(2, 1)], 120), // Firepit (1)
	new Recipe(RECIPETYPE.CRAFTING, [new ItemStack(5, 1)], [new ItemStack(6, 2)], 60), // Oak Planks (2)
	new Recipe(RECIPETYPE.CRAFTING, [new ItemStack(5, 4), new ItemStack(6, 4), new ItemStack(4, 1)], [new ItemStack(7, 1)], 120), // Wooden Crate (3)
	new Recipe(RECIPETYPE.CRAFTING, [new ItemStack(6, 6)], [new ItemStack(8, 1)], 60), // Sign (4) (TEMPORARY)
]

/**
*  Initializes a new server-side inventory.
*
* @param {real} [_slots] How many slots this inventory has.
* @param {string} [_name] Name of this inventory.
* @param {real} [_type] Type of this inventory.
* @param {array} [_params] Additional parameters, such as a whitelist.
*/
function Inventory(_slots = 1, _name = "", _type = INVTYPES.STORAGE, _params = []) constructor {
	host = other.id;
	name = _name;
	slots = _slots;
	type = _type;
	contents = array_create(_slots, new ItemStack());
	if (_type = INVTYPES.INPUT) {
		params = {
			whitelist : _params
		}
	}
}