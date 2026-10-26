class_name LookAheadCamera
extends Camera2D
## Player camera that looks ahead in the direction the player faces, so more
## of the level is visible in front of the player than behind.
##
## Moves the camera's `position` (never `offset`): Camera2D limits clamp the
## position but not the offset, and the view must never show past the level edges.
##
## Usage: add as a child of the player, set `player` to the parent and `stats`
## to `assets/data/camera_stats.tres`, then set the Camera2D limits to the level bounds.

## Player whose `facing` decides which side the camera looks ahead to.
@export var player: Player
## Look-ahead numbers (data-driven).
@export var stats: CameraStats


func _ready() -> void:
	position.x = player.facing * stats.look_ahead_distance


func _process(delta: float) -> void:
	position.x = move_toward(
		position.x,
		player.facing * stats.look_ahead_distance,
		stats.look_ahead_speed * delta
	)
