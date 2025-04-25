/// @description Game Management
// Autosave handling.
var _autosavetimer;
switch (global.settings.autosave_interval) {
	case 0: _autosavetimer = 360; break;
	case 1: _autosavetimer = 720; break;
	case 2: _autosavetimer = 1080; break;
	case 3: _autosavetimer = 1440; break;
	case 4: _autosavetimer = 2160; break;
	case 5: _autosavetimer = 4320; break;
	default: _autosavetimer = 1080;
}

// Time
// Increment Seconds
tick++;
if (tick >= 60) {
	sec++;
	tick = 0;
	// If not a dedicated server, increase playtime.
	if (obj_control.game_type != 2) {
		playtime++;
	}
	// If we have reached an autosave point, save the game.
	if (sec % _autosavetimer == 0) {
		save_game();
	}
}



