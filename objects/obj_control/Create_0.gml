/// @description Game Setup
global.text_map = load_json("lang/" + global.settings.language + ".json"); // Load language file.
global.game_version = "0.1a-exhib-1"; // Game Version
draw_set_font(fnt_main); // Set Font.
audio_falloff_set_model(audio_falloff_exponent_distance_scaled); // Configure Audio (not used at the moment)
game_type = 0; // Initialize Game Type
initialized = false; // Whether or not we have initialized the game.
global.field_cursor = "|"; // Cursor to show in text boxes.
alarm[0] = 15; // Cursor blink timer.

// Load audio groups
audio_group_load(audiogroup_ambience);
audio_group_load(audiogroup_entities);
audio_group_load(audiogroup_tiles);
audio_group_load(audiogroup_ui);

// Global variables.
global.hover_text = "";
global.hover_center = false;