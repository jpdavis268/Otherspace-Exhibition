/// @description Render Tiles
// Create tilemaps.
gtm = layer_tilemap_create("Ground", x, y, ts_ground, 16, 16);
ftm = layer_tilemap_create("Floor", x, y, ts_floor, 16, 16);
stm = layer_tilemap_create("Walls", x, y, ts_solid, 16, 16);

// Lower depth for drawing purposes.
depth = -10000;