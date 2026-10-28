class_name Level
extends Node2D
## Root of a level scene. Exposes the nodes the layout needs (player, respawn
## manager) and reports level completion when the goal flag is reached.
## Sets the player camera's right limit from `level_length`; the left, top and
## bottom limits stay as set in the scene (0 / 0 / 320).
##
## Implements: design/game-brief.md (MVP 4), story-005,
## design/levels/level-layouts.md (Conventions).
## Usage: put on the root Node2D of each level scene and assign every reference.

## Emitted once when the player reaches the goal flag.
signal completed

## Level width in pixels (camera `limit_right`).
@export var level_length: float = 3200.0
## The level's player.
@export var player: Player
## The player's camera; its `limit_right` is set from `level_length`.
@export var camera: Camera2D
## Lives, failure and checkpoints for this level.
@export var respawn_manager: RespawnManager
## The end-of-level flag.
@export var goal: LevelGoal


func _ready() -> void:
	assert(player != null, "Level: player is not assigned")
	assert(camera != null, "Level: camera is not assigned")
	assert(respawn_manager != null, "Level: respawn_manager is not assigned")
	assert(goal != null, "Level: goal is not assigned")
	assert(level_length > 0.0, "Level: level_length must be > 0")
	camera.limit_right = roundi(level_length)
	goal.reached.connect(completed.emit)
