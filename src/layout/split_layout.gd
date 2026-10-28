class_name SplitLayout
extends Control
## Main scene: top half is the game view (SubViewport), bottom half is the
## touch controls. Registers the keyboard input actions at startup and runs the
## level sequence: loads `levels` in order, carries the lives left to the next
## level and shows the main menu on game over or after the last level. Owns the
## menus' effects: pause (`get_tree().paused`), level choice and the way back to
## the main menu; `MenuLayer` and `TouchControls` only send signals.
##
## Implements: design/game-brief.md (MVP 4), story-005, story-007.
## Usage: set as `run/main_scene`; fill `levels` with the level scenes in play
## order (each root must use `level.gd`).

## Action name -> keyboard keys that trigger it (desktop testing aid).
const KEY_BINDINGS: Dictionary[StringName, Array] = {
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"jump": [KEY_SPACE, KEY_W, KEY_UP],
	&"ability": [KEY_J, KEY_E],
}

## Level scenes in play order. Each root must be a `Level`.
@export var levels: Array[PackedScene] = []

var _level_index: int = -1
var _level: Level = null
## True from a completion / game over until the next level is loaded; drops
## repeated requests in between.
var _loading: bool = false

@onready var _game_view: SubViewport = $Column/GameViewContainer/GameView
@onready var _hud: HealthHud = $Column/GameViewContainer/GameView/HudLayer/HealthHud
@onready var _touch_controls: TouchControls = $Column/TouchControls
@onready var _menus: MenuLayer = $Column/MenuLayer


func _ready() -> void:
	for action: StringName in KEY_BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode: Key in KEY_BINDINGS[action]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = keycode
			InputMap.action_add_event(action, key_event)
	assert(not levels.is_empty(), "SplitLayout: levels is empty")
	_touch_controls.menu_requested.connect(_on_menu_requested)
	_menus.start_requested.connect(_start_level.bind(0))
	_menus.level_chosen.connect(_start_level)
	_menus.resume_requested.connect(_on_resume_requested)
	_menus.main_menu_requested.connect(_show_main_menu)
	_show_main_menu()


## Frees the running level (if any), pauses the game and shows the main menu.
func _show_main_menu() -> void:
	_free_level()
	_loading = false
	_hud.visible = false
	_touch_controls.release_all()
	get_tree().paused = true
	_menus.open_main()


## Closes the menus, unpauses and starts `levels[index]` from scratch (fresh lives).
func _start_level(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	_menus.close()
	get_tree().paused = false
	_load_level(index, -1)


## MENU button: pauses the game and opens the pause menu. Ignored while no level
## runs, a level change is queued or a menu is already open.
func _on_menu_requested() -> void:
	if _level == null or _loading or _menus.is_open():
		return
	_touch_controls.release_all()
	get_tree().paused = true
	_menus.open_pause()


func _on_resume_requested() -> void:
	_menus.close()
	get_tree().paused = false


## Removes the current level at once so two level cameras never exist.
func _free_level() -> void:
	if _level != null:
		_game_view.remove_child(_level)
		_level.queue_free()
		_level = null


## Replaces the current level with `levels[index]`. `carried_lives` > 0 sets the
## new level's lives; otherwise it starts with `start_lives`.
func _load_level(index: int, carried_lives: int) -> void:
	assert(index >= 0 and index < levels.size(), "SplitLayout: level index out of range")
	_free_level()
	var level := levels[index].instantiate() as Level
	assert(level != null, "SplitLayout: level root is not a Level")
	_level_index = index
	_level = level
	_game_view.add_child(level)
	# Below the HUD layer.
	_game_view.move_child(level, 0)
	if carried_lives > 0:
		level.respawn_manager.set_lives(carried_lives)
	_hud.bind(level.player.health, level.respawn_manager, level.player.ability_holder)
	level.completed.connect(_on_level_completed)
	level.respawn_manager.game_over.connect(_on_game_over)
	_hud.visible = true
	_loading = false


func _on_level_completed() -> void:
	if _loading:
		return
	_loading = true
	var next: int = _level_index + 1
	if next < levels.size():
		_load_level.call_deferred(next, _level.respawn_manager.lives)
		return
	_show_main_menu.call_deferred()


func _on_game_over() -> void:
	if _loading:
		return
	_loading = true
	_show_main_menu.call_deferred()
