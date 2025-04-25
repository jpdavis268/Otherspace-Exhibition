/// @description Sprite and Nightlight
// May use a shader for this later.
var _chunk = client_get_chunk(x, y);
if (_chunk != noone) {
	switch (tilemap_get_at_pixel(_chunk.gtm, x, y - sprite_height * 0.5)) {
		case 3: // Shallow Water
			draw_sprite_part(self.sprite_index, -1, 0, 0, sprite_width, sprite_height - 8, x - (sprite_width / 2), y - sprite_height);
			break;
		case 4: // Deep Water
			draw_sprite_part(self.sprite_index, -1, 0, 0, sprite_width, sprite_height - 16, x - (sprite_width / 2), y - sprite_height);
			break;
		default: draw_self();
	}
}

// Draw a small light on the player so they can be seen in the dark.
draw_light(x, y - 20, 0.02, c_white, 0.05);