/// @description Light
draw_self();

// Emit Light if Active
if (active) {
	draw_light(x, y, range, c_orange, 1);
}