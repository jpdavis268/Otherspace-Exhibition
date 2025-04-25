/// @description World Generation
switch (global.map_type) {
	case 0: { // Default
		for (var _x = 0; _x < 16; _x++) {
			for (var _y = 0; _y < 16; _y++) {
				// Noise Generation
				var _nx = (_x / 16) + chunk_x;
				var _ny = (_y / 16) + chunk_y;
		
				// Features
				var _elev = perlin_noise(_nx / 4, _ny / 4) // Base
					+ 0.2 * perlin_noise(_nx * 2, _ny * 2) // Roughness
				_elev /= 1.2; // Octave Correction
		
				// Level out spawn area to ensure players don't appear in a wall.
				var _dist = sqrt(power(_nx, 2) + power(_ny, 2));
				var _diff = _elev - 0.5;
				var _adj = _diff / (_dist + 1);
				_elev -= _adj;
			
				var _gt = 1;
				var _st = 0;
			
				if (_elev < 0.30) { // Deep Water
					_gt = 4;
				}
				else if (_elev < 0.35) { // Shallow Water
					_gt = 3;
				}
				else if (_elev < 0.40) { // Sand
					_gt = 2;
				}
				else if (_elev < 0.60) { // Grass

				}
				else if (_elev < 0.65) { // Dirt
					_st = 1;
				}
				else { // Stone
					_st = 2;
					_gt = 5;
				}
		
				// Resource Spawning
				// Only spawn resources on grass and sand with no solid tile.
				if ((_gt == 1 || _gt == 2) && _st = 0) {
					var _rs = perlin_noise(_nx * 50, _ny * 50); 
					if (_rs > 0.83) {
						// Compare location to a checkerboard pattern and spawn either a branch or rock depending
						// on where it is.
						_st = (_x % 2 == _y % 2) ? 3 : 4;
					}
				}
		
				// Set tiles
				tilemap_set(gtm, _gt, _x, _y);
				tilemap_set(stm, _st, _x, _y);
				
				// Generate trees
				if (_gt == 1 && _st == 0) {
					var _fm = (perlin_noise(_nx, _ny) + perlin_noise(_nx * 25, _ny * 25)) / 2;
					if (_fm > 0.76) {
						instance_create_layer((chunk_x * 16 + _x) * 32 + 16, (chunk_y * 16 + _y + 1) * 32, "Server", obj_oaktree);
					}
				}
			}
		}
	} break;
	case 1: { // Lab Tiles
		for (var _x = 0; _x < 16; _x++) {
			for (var _y = 0; _y < 16; _y++) {
				// Generate checkerboard pattern.
				tilemap_set(gtm, (_x % 2 == _y % 2) ? 6 : 7, _x, _y);
			}
		}
	} break;
}