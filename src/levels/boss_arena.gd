class_name BossArena
extends Node
## The boss arena of a level: closes the gate behind the player when they pass
## the entrance X (starting the fight), shows the clear message when the boss is
## defeated and emits `cleared` after the message time.
##
## The gate stays closed after the player dies in the fight (the checkpoint sits
## inside the arena); it opens again only on game over. If the boss is restored
## while the clear message is showing, the message and countdown are cancelled.
##
## Implements: design/game-brief.md (MVP 5), story-006.
## Usage: add to the level, assign every reference; give the level's `LevelGoal`
## this node as its `arena`.

## Emitted once when the clear message time has run out after the boss fell.
signal cleared

## The player whose X is compared with `trigger_x`.
@export var player: Player
## The boss fought in this arena.
@export var boss: Boss
## Solid block that closes behind the player (open = hidden, no collision).
@export var gate: Block
## The player's X from which the gate closes and the fight starts. Must be
## right of the arena's checkpoint so a death always respawns inside the arena.
@export var trigger_x: float = 0.0
## Lives and game over of this level (the gate reopens on game over).
@export var respawn_manager: RespawnManager
## Label shown over the game view when the boss is defeated (starts hidden).
@export var message_label: Label
## Text of the clear message.
@export var message_text: String = "클리어!"
## Camera of the level. While the gate is closed its left limit is
## `fight_camera_limit_left`, so the whole arena (and every telegraph) stays
## in view; it is restored when the gate opens.
@export var camera: Camera2D
## Camera left limit during the fight (level right edge minus the view width).
@export var fight_camera_limit_left: int = 0

var _is_closed: bool = false
var _clear_left: float = -1.0
var _is_cleared: bool = false
var _start_limit_left: int = 0


func _ready() -> void:
	assert(player != null, "BossArena: player is not assigned")
	assert(boss != null, "BossArena: boss is not assigned")
	assert(gate != null, "BossArena: gate is not assigned")
	assert(respawn_manager != null, "BossArena: respawn_manager is not assigned")
	assert(message_label != null, "BossArena: message_label is not assigned")
	assert(camera != null, "BossArena: camera is not assigned")
	_start_limit_left = camera.limit_left
	_set_gate(false)
	message_label.hide()
	boss.defeated.connect(_on_boss_defeated)
	boss.restored.connect(_on_boss_restored)
	respawn_manager.game_over.connect(_on_game_over)


func _physics_process(delta: float) -> void:
	if not _is_closed and player.global_position.x >= trigger_x:
		_set_gate(true)
		boss.start_fight()
	if _clear_left >= 0.0:
		_clear_left -= delta
		if _clear_left < 0.0:
			_clear_left = -1.0
			_is_cleared = true
			cleared.emit()


## True once `cleared` has been emitted.
func is_cleared() -> bool:
	return _is_cleared


func _set_gate(is_closed: bool) -> void:
	_is_closed = is_closed
	gate.visible = is_closed
	# Layer 1 = world; 0 = no collision.
	gate.collision_layer = 1 if is_closed else 0
	camera.limit_left = fight_camera_limit_left if is_closed else _start_limit_left


func _on_boss_defeated() -> void:
	message_label.text = message_text
	message_label.show()
	_clear_left = (boss.stats as BossStats).clear_message_time


func _on_boss_restored() -> void:
	if _is_cleared:
		return
	_clear_left = -1.0
	message_label.hide()


func _on_game_over() -> void:
	_set_gate(false)
	boss.stop_fight()
