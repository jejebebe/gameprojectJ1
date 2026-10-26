class_name Player
extends CharacterBody2D
## Side-view player: left/right movement and variable-height jump.
## Reads the input actions `move_left`, `move_right` and `jump`, so touch,
## mouse and keyboard all drive it the same way.
##
## Usage: instance `player.tscn`; tune numbers in `assets/data/player_stats.tres`.

## Movement numbers (data-driven).
@export var stats: PlayerStats

## Direction the player last moved in: 1.0 = right, -1.0 = left. Kept when the
## player stops. Example: `camera.position.x = player.facing * 60.0`.
var facing: float = 1.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + stats.gravity * delta, stats.max_fall_speed)
	elif Input.is_action_just_pressed(&"jump"):
		velocity.y = stats.jump_velocity

	# Releasing jump early cuts the rise short: the longer it is held, the higher.
	if Input.is_action_just_released(&"jump") and velocity.y < 0.0:
		velocity.y *= stats.jump_cut_factor

	var axis := Input.get_axis(&"move_left", &"move_right")
	if axis != 0.0:
		facing = signf(axis)
	velocity.x = axis * stats.move_speed
	move_and_slide()
