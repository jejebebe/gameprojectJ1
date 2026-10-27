class_name Walker
extends Enemy
## Patrols the floor left and right, reversing at both ends and at walls.
##
## Implements: design/game-brief.md (MVP 2), story-003.


func _behave(delta: float) -> void:
	_apply_gravity(delta)
	_patrol_step()
