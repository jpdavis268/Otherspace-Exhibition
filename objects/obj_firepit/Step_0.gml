 /// @description Operation
// Send update to interfacing clients while burning.
if (active) {
	entity_send_interface_update(3, [burntime]);
}

// Consume fuel or burn out when burn timer reaches 0.
if (burntime < 1) {
	// Check if there is any fuel left, and burn some if there is.
	if (fuel_input.contents[0].stacksize > 0) {
		fuel_input.contents[0].stacksize--;
		send_inventory_update(0, fuel_input);
		burntime = 3600;
		// If the fire was out, reignite it.
		if (!active) {
			active = true;
			entity_send_update(2, [true]);
		}
	}
	// No fuel left, fire burns out.
	else {
		if (active) {
			active = false;
			entity_send_update(2, [false]);
		}
	}
}
else {
	// Decrement burn timer
	burntime--;
	if (!active) {
		active = true;
		entity_send_update(2, [true]);
	}	
}
