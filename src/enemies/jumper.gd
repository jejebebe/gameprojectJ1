class_name Jumper
extends Enemy
## Stays in place and jumps at a fixed interval.
##
## Implements: design/game-brief.md (MVP 2), story-003.

var _time_since_jump: float = 0.0


func _behave(delta: float) -> void:
	_apply_gravity(delta)
	_time_since_jump += delta
	if is_on_floor() and _time_since_jump >= stats.jump_interval:
		_time_since_jump = 0.0
		velocity.y = stats.jump_velocity
	move_and_slide()


## Jumps in place, so it keeps one facing: left, toward a player coming from
## the level start.
func _start_facing() -> float:
	return Vector2.LEFT.x


## Restarts the jump timer when the enemy is reset to its start.
func _reset_behaviour() -> void:
	_time_since_jump = 0.0
