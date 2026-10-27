class_name Checkpoint
extends Node2D
## A flag that marks a respawn point. The node's own position is where the
## player is put back. It has no collision: RespawnManager activates it when the
## player's X crosses the flag's X (airborne counts).
##
## A flag is consumed when it becomes active or when a later flag replaces it.
## A consumed flag is hidden and never activates again until `reset()`.
##
## Implements: design/game-brief.md (MVP 6). Placement is decided in story 005.

var _consumed: bool = false


## True once this flag was activated or removed; it can no longer activate.
func is_consumed() -> bool:
	return _consumed


## Marks this flag as the active checkpoint. It stays visible and is consumed.
func activate() -> void:
	_consumed = true
	visible = true


## Consumes this flag and hides it (a newer checkpoint replaced it, or it was
## crossed in the same frame as a farther one). It cannot activate again.
func remove() -> void:
	_consumed = true
	visible = false


## Restores the flag: visible again and armed. Used on game over.
func reset() -> void:
	_consumed = false
	visible = true
