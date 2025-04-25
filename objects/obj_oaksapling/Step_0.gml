/// @description Growth
age++;

if (age > growtime) {
	instance_create_layer(x, y, "Server", obj_oaktree);
	instance_destroy();
}

if (age / growtime * 4 == floor(age / growtime * 4)) {
	entity_send_update(0, [floor(age / growtime * 4)])
}