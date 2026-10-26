class_name TouchControls
extends Control
## Bottom-half control panel: left, right, jump, plus ability and menu slots
## (the last two are visible but do nothing yet).
##
## Every pointer (each touch finger, plus the mouse) is tracked on its own, so
## one finger can hold "move" while another presses "jump". Pressed buttons
## drive the input actions `move_left`, `move_right` and `jump`. The panel only
## presses or releases an action when its own pointer state for that action
## changes, so keyboard input on the same action is not cancelled by unrelated
## touches or clicks.
##
## Usage: instance `touch_controls.tscn` in the bottom half of the screen.

const MOUSE_POINTER: int = -1

## Gap in pixels between the bottom of the panel and the bottom edge of the
## move/jump/ability button cluster. Example: `bottom_margin = 48.0` puts the
## bottom of the move and jump buttons 48 px above the screen's bottom edge.
@export var bottom_margin: float = 48.0

@onready var _cluster: Control = $BottomCluster
@onready var _left: Panel = $BottomCluster/LeftButton
@onready var _right: Panel = $BottomCluster/RightButton
@onready var _jump: Panel = $BottomCluster/JumpButton

## Button panel -> input action it drives.
var _actions: Dictionary[Panel, StringName] = {}
## Pointer id (touch index, or MOUSE_POINTER) -> panel it currently holds.
var _held: Dictionary[int, Panel] = {}
## Input action -> whether a touch/mouse pointer currently holds it down.
var _pointer_down: Dictionary[StringName, bool] = {}


func _ready() -> void:
	# Keep the cluster's height as laid out in the scene; only its bottom gap moves.
	var cluster_height: float = _cluster.offset_bottom - _cluster.offset_top
	_cluster.offset_bottom = -bottom_margin
	_cluster.offset_top = -bottom_margin - cluster_height
	_actions = {
		_left: &"move_left",
		_right: &"move_right",
		_jump: &"jump",
	}


func _input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch != null:
		_set_pointer(touch.index, touch.pressed, touch.position)
		return
	var drag := event as InputEventScreenDrag
	if drag != null:
		_set_pointer(drag.index, true, drag.position)
		return
	var button := event as InputEventMouseButton
	if button != null:
		if button.button_index == MOUSE_BUTTON_LEFT:
			_set_pointer(MOUSE_POINTER, button.pressed, button.position)
		return
	var motion := event as InputEventMouseMotion
	if motion != null and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		_set_pointer(MOUSE_POINTER, true, motion.position)


## Moves a pointer to `screen_pos` (or releases it when `pressed` is false)
## and presses/releases only the actions whose pointer state changed.
func _set_pointer(pointer: int, pressed: bool, screen_pos: Vector2) -> void:
	_held.erase(pointer)
	if pressed:
		for panel: Panel in _actions:
			if panel.get_global_rect().has_point(screen_pos):
				_held[pointer] = panel
				break
	for panel: Panel in _actions:
		var down: bool = _held.values().has(panel)
		panel.modulate = Color(0.7, 0.7, 0.7) if down else Color.WHITE
		var action: StringName = _actions[panel]
		var was_down: bool = _pointer_down.get(action, false)
		if down == was_down:
			continue
		_pointer_down[action] = down
		if down:
			Input.action_press(action)
		else:
			Input.action_release(action)
