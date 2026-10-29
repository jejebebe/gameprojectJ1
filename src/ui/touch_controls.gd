class_name TouchControls
extends Control
## Bottom-half control panel: left, right, jump and ability buttons, plus a
## MENU button that only announces `menu_requested` (the owner opens the menu).
##
## Every pointer (each touch finger, plus the mouse) is tracked on its own, so
## one finger can hold "move" while another presses "jump". Pressed buttons
## drive the input actions `move_left`, `move_right`, `jump` and `ability`. The panel only
## presses or releases an action when its own pointer state for that action
## changes, so keyboard input on the same action is not cancelled by unrelated
## touches or clicks.
##
## Looks (art bible §7): cream control panel behind everything, each button a
## navy 9-slice with a centred icon. A held button swaps to `pressed_style`
## (face drawn 4 px lower, cream border) and its icon moves down by
## `press_shift`. The ability button shows the held ability's icon from
## `ability_icons`, or `disabled_style` + `ability_none_icon` when nothing is
## held; it still drives the `ability` action either way (the player ignores it).
##
## Usage: instance `touch_controls.tscn` in the bottom half of the screen and
## call `bind_ability_holder` whenever a level (and its player) is loaded.

## Emitted when a pointer is pressed on the MENU button.
signal menu_requested

const MOUSE_POINTER: int = -1

## Gap in pixels between the bottom of the panel and the bottom edge of the
## move/jump/ability button cluster. Example: `bottom_margin = 48.0` puts the
## bottom of the move and jump buttons 48 px above the screen's bottom edge.
@export var bottom_margin: float = 48.0

@export_group("Looks")
## Button background while not held.
@export var normal_style: StyleBox
## Button background while held (face lower, cream border).
@export var pressed_style: StyleBox
## Ability button background while no ability is held.
@export var disabled_style: StyleBox
## Screen pixels the icon moves down while its button is held (matches the
## face drop baked into `pressed_style`).
@export var press_shift: float = 4.0
## Ability id (`Ability.ability_id`) -> icon on the ability button.
@export var ability_icons: Dictionary[StringName, Texture2D] = {}
## Icon on the ability button when nothing is held (or the id has no icon).
@export var ability_none_icon: Texture2D

## Source of `ability_changed`; set through `bind_ability_holder`.
var ability_holder: AbilityHolder = null

@onready var _cluster: Control = $BottomCluster
@onready var _left: Panel = $BottomCluster/LeftButton
@onready var _right: Panel = $BottomCluster/RightButton
@onready var _jump: Panel = $BottomCluster/JumpButton
@onready var _ability: Panel = $BottomCluster/AbilityButton
@onready var _menu: Panel = $MenuButton

## Button panel -> input action it drives.
var _actions: Dictionary[Panel, StringName] = {}
## Pointer id (touch index, or MOUSE_POINTER) -> panel it currently holds.
var _held: Dictionary[int, Panel] = {}
## Input action -> whether a touch/mouse pointer currently holds it down.
var _pointer_down: Dictionary[StringName, bool] = {}
## Pointer ids whose press started on the MENU button (menu opens on release).
var _menu_pressed: Dictionary[int, bool] = {}
## Button panel -> its icon's offset_top / offset_bottom when not held.
var _icon_rest: Dictionary[Panel, Vector2] = {}
## True while the bound holder holds an ability (ability button enabled look).
var _has_ability: bool = false


func _ready() -> void:
	# Keep the cluster's height as laid out in the scene; only its bottom gap moves.
	var cluster_height: float = _cluster.offset_bottom - _cluster.offset_top
	_cluster.offset_bottom = -bottom_margin
	_cluster.offset_top = -bottom_margin - cluster_height
	_actions = {
		_left: &"move_left",
		_right: &"move_right",
		_jump: &"jump",
		_ability: &"ability",
	}
	for panel: Panel in [_left, _right, _jump, _ability, _menu]:
		var icon := panel.get_node(^"Icon") as Control
		_icon_rest[panel] = Vector2(icon.offset_top, icon.offset_bottom)
	_on_ability_changed(null)


## Switches the ability button to a new holder (e.g. after a level change):
## disconnects the previous one, connects its `ability_changed` and shows its
## current ability at once. Display only; the holder is never changed.
func bind_ability_holder(new_holder: AbilityHolder) -> void:
	assert(new_holder != null, "TouchControls.bind_ability_holder: holder is null")
	if (
		is_instance_valid(ability_holder)
		and ability_holder.ability_changed.is_connected(_on_ability_changed)
	):
		ability_holder.ability_changed.disconnect(_on_ability_changed)
	ability_holder = new_holder
	ability_holder.ability_changed.connect(_on_ability_changed)
	_on_ability_changed(ability_holder.current)


func _on_ability_changed(ability: Ability) -> void:
	var texture: Texture2D = null
	if ability != null:
		texture = ability_icons.get(ability.ability_id, null)
	_has_ability = ability != null
	(_ability.get_node(^"Icon") as TextureRect).texture = (
		texture if texture != null else ability_none_icon
	)
	_apply_held()


func _input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch != null:
		_set_pointer(touch.index, touch.pressed, touch.position)
		_check_menu(touch.index, touch.pressed, touch.position)
		return
	var drag := event as InputEventScreenDrag
	if drag != null:
		_set_pointer(drag.index, true, drag.position)
		return
	var button := event as InputEventMouseButton
	if button != null:
		if button.button_index == MOUSE_BUTTON_LEFT:
			_set_pointer(MOUSE_POINTER, button.pressed, button.position)
			_check_menu(MOUSE_POINTER, button.pressed, button.position)
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
	_apply_held()


## Releases every pointer and every action this panel is holding down (call when
## a menu opens, so no button stays stuck). Keyboard input is not touched.
func release_all() -> void:
	_held.clear()
	_menu_pressed.clear()
	_apply_held()


## Emits `menu_requested` when a pointer that was pressed on the MENU button is
## released on it. Opening on release (not press) keeps the same tap from also
## reaching a menu button that appears under the finger.
func _check_menu(pointer: int, pressed: bool, screen_pos: Vector2) -> void:
	var on_menu := _menu.get_global_rect().has_point(screen_pos)
	if pressed:
		if on_menu:
			_menu_pressed[pointer] = true
			_set_look(_menu, true)
		return
	var started_on_menu: bool = _menu_pressed.get(pointer, false)
	_menu_pressed.erase(pointer)
	_set_look(_menu, not _menu_pressed.is_empty())
	if started_on_menu and on_menu:
		get_viewport().set_input_as_handled()
		menu_requested.emit()


## Syncs button looks and input actions with `_held`.
func _apply_held() -> void:
	_set_look(_menu, not _menu_pressed.is_empty())
	for panel: Panel in _actions:
		var down: bool = _held.values().has(panel)
		_set_look(panel, down)
		var action: StringName = _actions[panel]
		var was_down: bool = _pointer_down.get(action, false)
		if down == was_down:
			continue
		_pointer_down[action] = down
		if down:
			Input.action_press(action)
		else:
			Input.action_release(action)


## Shows `panel` held or not: background style and icon height. The ability
## button keeps `disabled_style` (and its rest icon height) while no ability
## is held.
func _set_look(panel: Panel, down: bool) -> void:
	var style: StyleBox = pressed_style if down else normal_style
	var shift: float = press_shift if down else 0.0
	if panel == _ability and not _has_ability:
		style = disabled_style
		shift = 0.0
	if style != null:
		panel.add_theme_stylebox_override(&"panel", style)
	var icon := panel.get_node(^"Icon") as Control
	var rest: Vector2 = _icon_rest[panel]
	icon.offset_top = rest.x + shift
	icon.offset_bottom = rest.y + shift
