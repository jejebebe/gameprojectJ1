class_name SplitLayout
extends Control
## Main scene: top half is the game view (SubViewport), bottom half is the
## touch controls. Registers the keyboard input actions at startup.
##
## Usage: set as `run/main_scene`.

## Action name -> keyboard keys that trigger it (desktop testing aid).
const KEY_BINDINGS: Dictionary[StringName, Array] = {
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"jump": [KEY_SPACE, KEY_W, KEY_UP],
	&"ability": [KEY_J, KEY_E],
}


func _ready() -> void:
	for action: StringName in KEY_BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode: Key in KEY_BINDINGS[action]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = keycode
			InputMap.action_add_event(action, key_event)
