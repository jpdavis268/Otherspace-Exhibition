/// @description Draw Item
// Calculate drawing parameters
var _i = item.contents[0].item_id + 1; // Get item
var _w = sprite_get_width(spr_itemmap) / 32; // Calculate width of item on texture map.
var _x = (32 * _i) - floor(_i / _w) * (_w * 32); // Get x offset on item texture map
var _y = (32 * floor((32 * _i) / (_w * 32))); // Get y offset

if (item.contents[0].stacksize <= 1) {
	// If single item, draw the sprite once.
	draw_sprite_part_ext(spr_itemmap, -1, _x, _y, 32, 32, x - 8, y - 8, 0.5, 0.5, c_white, 1);
}
else if (item.contents[0].stacksize == 2) {
	// If two items, draw two adjacent sprites.
	draw_sprite_part_ext(spr_itemmap, -1, _x, _y, 32, 32, x - 4, y - 8, 0.5, 0.5, c_white, 1);
	draw_sprite_part_ext(spr_itemmap, -1, _x, _y, 32, 32, x - 12, y - 8, 0.5, 0.5, c_white, 1);
}
else {
	// If three or more items, draw three sprites in a stack.
	draw_sprite_part_ext(spr_itemmap, -1, _x, _y, 32, 32, x - 8, y - 4, 0.5, 0.5, c_white, 1);
	draw_sprite_part_ext(spr_itemmap, -1, _x, _y, 32, 32, x - 4, y - 12, 0.5, 0.5, c_white, 1);
	draw_sprite_part_ext(spr_itemmap, -1, _x, _y, 32, 32, x - 12, y - 12, 0.5, 0.5, c_white, 1);
}