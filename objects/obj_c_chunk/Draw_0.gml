/// @description Debug Chunk Grid
if (obj_inputhandler.show_chunks) {
	draw_text(x, y, string(floor(x / 512)) + ", " + string(floor(y / 512)));
	draw_rectangle(x, y, x + 511, y + 511, true);
}