class_name Burnable
extends StaticBody2D
## Wall that blocks the player and enemies until a fireball burns it. After
## `burn()` its collision is removed at once, it flashes and fades, then it is
## hidden. `reset()` brings it back (RespawnManager calls it on game over).
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: instance `burnable.tscn` into the level.

## Seconds of the whole burn animation (flash, then fade).
@export var burn_time: float = 0.5
## Colour the wall flashes to while burning.
@export var burn_color: Color = Color(1.0, 0.45, 0.1)
## Share of `burn_time` spent flashing to `burn_color`; the rest is the fade.
@export_range(0.0, 1.0) var flash_fraction: float = 0.4

var _is_burning: bool = false
var _burn_tween: Tween
var _start_color: Color
var _start_modulate: Color

@onready var _shape: CollisionShape2D = $Shape
@onready var _look: ColorRect = $Look


func _ready() -> void:
	_start_color = _look.color
	_start_modulate = _look.modulate


## Burns the wall away. Does nothing if it is already burning.
func burn() -> void:
	if _is_burning:
		return
	_is_burning = true
	_shape.set_deferred(&"disabled", true)
	_burn_tween = create_tween()
	_burn_tween.tween_property(_look, "color", burn_color, burn_time * flash_fraction)
	_burn_tween.tween_property(
		_look, "modulate:a", 0.0, burn_time * (1.0 - flash_fraction)
	)
	_burn_tween.tween_callback(hide)


## Restores the wall (look and collision), also mid-burn. Safe on an intact wall.
func reset() -> void:
	if _burn_tween != null and _burn_tween.is_valid():
		_burn_tween.kill()
	_burn_tween = null
	_is_burning = false
	_look.color = _start_color
	_look.modulate = _start_modulate
	show()
	_shape.set_deferred(&"disabled", false)
