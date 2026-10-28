class_name LevelGoal
extends Node2D
## End-of-level flag. Fires `reached` once when the player's X reaches the
## flag's X (airborne counts, same rule as checkpoints). It has no collision
## and is inert after it fires.
##
## Implements: design/game-brief.md (MVP 4), story-005.
## Usage: instance `level_goal.tscn` at the level end and assign `player`.

## Emitted once when the player reaches the flag.
signal reached

## The player whose X is compared with the flag's X.
@export var player: Player

## Optional boss arena. When set, the flag is inert until the arena reports
## `cleared` (boss defeated and clear message shown); the player's X is ignored.
@export var arena: BossArena

var _triggered: bool = false


func _ready() -> void:
	assert(player != null, "LevelGoal: player is not assigned")
	if arena != null:
		set_physics_process(false)
		arena.cleared.connect(_trigger)


func _physics_process(_delta: float) -> void:
	if _triggered:
		return
	if player.global_position.x >= global_position.x:
		_trigger()


func _trigger() -> void:
	if _triggered:
		return
	_triggered = true
	set_physics_process(false)
	reached.emit()


## True once the flag has fired `reached`.
func is_triggered() -> bool:
	return _triggered
