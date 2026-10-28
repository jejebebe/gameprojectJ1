class_name MenuLayer
extends Control
## Menus of the game: main menu, pause menu and level select. Display and input
## only: it emits a signal for every choice and the owner (`SplitLayout`) decides
## what happens to the game. Runs while the tree is paused
## (`process_mode = Always`, set in the scene).
##
## Main menu and level select cover the whole 360x640 column; the pause menu
## covers only the bottom control area so the paused game stays visible.
## Buttons act on release and show a pressed look via `modulate`, so they work
## the same with touch (emulated mouse) and mouse, with no hover needed.
##
## Implements: story-007 (menu and level select).
## Usage: instance `menu_layer.tscn` over the column, connect the signals, then
## call `open_main()` / `open_pause()` / `close()`.

## The player chose "start" in the main menu (level 1, fresh lives).
signal start_requested
## The player chose a level (0-based) in the level select.
signal level_chosen(index: int)
## The player chose "continue" in the pause menu.
signal resume_requested
## The player chose "main menu" in the pause menu.
signal main_menu_requested

## Which menu is showing.
enum Screen { NONE, MAIN, PAUSE, LEVEL_SELECT }

## Colour multiplied onto a button while it is held down.
@export var pressed_modulate: Color = Color(0.7, 0.7, 0.7)

var _screen: Screen = Screen.NONE
## Menu that the level select's back button returns to.
var _select_return: Screen = Screen.MAIN

@onready var _main: Control = $MainMenu
@onready var _pause: Control = $PauseMenu
@onready var _select: Control = $LevelSelect
@onready var _start_button: Button = $MainMenu/Box/StartButton
@onready var _main_select_button: Button = $MainMenu/Box/LevelSelectButton
@onready var _resume_button: Button = $PauseMenu/Box/ResumeButton
@onready var _pause_select_button: Button = $PauseMenu/Box/LevelSelectButton
@onready var _to_main_button: Button = $PauseMenu/Box/MainMenuButton
@onready var _level_buttons: Array[Button] = [
	$LevelSelect/Box/Level1Button,
	$LevelSelect/Box/Level2Button,
	$LevelSelect/Box/Level3Button,
]
@onready var _back_button: Button = $LevelSelect/Box/BackButton


func _ready() -> void:
	_start_button.pressed.connect(start_requested.emit)
	_main_select_button.pressed.connect(_open_select.bind(Screen.MAIN))
	_resume_button.pressed.connect(resume_requested.emit)
	_pause_select_button.pressed.connect(_open_select.bind(Screen.PAUSE))
	_to_main_button.pressed.connect(main_menu_requested.emit)
	for i: int in _level_buttons.size():
		_level_buttons[i].pressed.connect(level_chosen.emit.bind(i))
	_back_button.pressed.connect(_on_back_pressed)
	for node: Node in find_children("*", "Button", true, false):
		var button := node as Button
		button.button_down.connect(_set_button_look.bind(button, true))
		button.button_up.connect(_set_button_look.bind(button, false))
	_show(Screen.NONE)


## True while any menu is showing.
func is_open() -> bool:
	return _screen != Screen.NONE


## Shows the main menu.
func open_main() -> void:
	_show(Screen.MAIN)


## Shows the pause menu over the bottom control area.
func open_pause() -> void:
	_show(Screen.PAUSE)


## Hides every menu.
func close() -> void:
	_show(Screen.NONE)


func _open_select(return_to: Screen) -> void:
	_select_return = return_to
	_show(Screen.LEVEL_SELECT)


func _on_back_pressed() -> void:
	_show(_select_return)


func _show(screen: Screen) -> void:
	_screen = screen
	visible = screen != Screen.NONE
	_main.visible = screen == Screen.MAIN
	_pause.visible = screen == Screen.PAUSE
	_select.visible = screen == Screen.LEVEL_SELECT
	# Reset any pressed look left from a button that was hidden mid-press.
	for node: Node in find_children("*", "Button", true, false):
		(node as Button).modulate = Color.WHITE
	# Keyboard / gamepad focus starts on the first button (separate from touch
	# focus since 4.6, see docs/engine-reference/godot/modules/ui.md).
	match screen:
		Screen.MAIN:
			_start_button.grab_focus()
		Screen.PAUSE:
			_resume_button.grab_focus()
		Screen.LEVEL_SELECT:
			_level_buttons[0].grab_focus()


func _set_button_look(button: Button, down: bool) -> void:
	button.modulate = pressed_modulate if down else Color.WHITE
