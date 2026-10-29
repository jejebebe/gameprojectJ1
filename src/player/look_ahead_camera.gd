class_name LookAheadCamera
extends Camera2D
## Player camera that looks ahead in the direction the player faces, so more
## of the level is visible in front of the player than behind.
##
## Focus: while `set_focus(target)` is active (e.g. the boss during the boss
## fight) the camera instead aims between the player and the target, at
## `stats.focus_weight` of the way from the player to the target (0.5 = the
## midpoint), so both stay in view. It slides there at `stats.look_ahead_speed`,
## never snapping; `clear_focus()` returns to the normal look-ahead. If the two
## are farther apart than the view, the aim is clamped so the player stays
## `stats.focus_player_margin` inside the view edge (the player wins).
##
## Moves the camera's `position` (never `offset`): Camera2D limits clamp the
## position but not the offset, and the view must never show past the level edges.
##
## Implements: story-013 (boss fight camera follows Jei and the boss).
## Usage: add as a child of the player, set `player` to the parent and `stats`
## to `assets/data/camera_stats.tres`, then set the Camera2D limits to the level bounds.

## Player whose `facing` decides which side the camera looks ahead to.
@export var player: Player
## Look-ahead numbers (data-driven).
@export var stats: CameraStats

var _focus: Node2D = null


func _ready() -> void:
	position.x = player.facing * stats.look_ahead_distance


func _process(delta: float) -> void:
	position.x = move_toward(position.x, _target_x(), stats.look_ahead_speed * delta)


## Aims the camera between the player and `target` until `clear_focus()`.
func set_focus(target: Node2D) -> void:
	_focus = target


## Returns to the normal look-ahead in the facing direction.
func clear_focus() -> void:
	_focus = null


## The current focus target, or null.
func get_focus() -> Node2D:
	return _focus


## Desired local X (the camera is a child of the player, so local X is the
## offset from the player).
func _target_x() -> float:
	if _focus != null and is_instance_valid(_focus):
		var toward_focus: float = (_focus.global_position.x - player.global_position.x) * stats.focus_weight
		# Keep the player inside the view even when the two are too far apart.
		var max_offset: float = maxf(
			get_viewport_rect().size.x * 0.5 / zoom.x - stats.focus_player_margin, 0.0
		)
		return clampf(toward_focus, -max_offset, max_offset)
	return player.facing * stats.look_ahead_distance
