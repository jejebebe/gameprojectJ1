class_name Flyer
extends Enemy
## Flies back and forth horizontally at a fixed height, with an optional
## vertical bob. No gravity.
##
## Implements: design/game-brief.md (MVP 2), story-003.

var _bob_time: float = 0.0
var _origin_y: float = 0.0


func _ready() -> void:
	super()
	_origin_y = global_position.y


func _behave(delta: float) -> void:
	_bob_time += delta
	# Height is set directly from the placed height, so it can never drift.
	global_position.y = _origin_y + stats.bob_amplitude * sin(stats.bob_speed * _bob_time)
	velocity.y = 0.0
	_patrol_step()


## Restarts the bob phase when the enemy is reset; the height comes back with
## `global_position` and `_origin_y` stays the placed height.
func _reset_behaviour() -> void:
	_bob_time = 0.0
