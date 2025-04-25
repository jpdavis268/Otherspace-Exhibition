/// @description Setup
// Chat/Console Management
chat_enabled = false; // Whether chat is enabled.
chat_text_[0] = ""; // Chat text array.
input_history_[0] = ""; // Previously sent messages/commands.
history_scroll = 0; // Input history scroll offset.
chat_text_currentline = ""; // Current Message
input_position = 0; // Text input cursor position.
input_position_offset = 0; // Offset of cursor in input string.
last_line_size = 0; // Size of last message processed when drawing.
scroll_center = 0; // Center of scroll bar.
scroll_position = 0; // Position of scroll bar.
chat_window_floor = 0; // Offset of chat history.
scroll_range = 0; // How far scroll bar can be moved.
scroll_mouse_selected = false; // Whether scroll bar is selected.
scroll_color = c_gray; // Scroll Color
chat_window = 0; // Percentage of chat history visible.
chat_recent_[0] = 1; // Show how much time the "recent" messages have until they fade.