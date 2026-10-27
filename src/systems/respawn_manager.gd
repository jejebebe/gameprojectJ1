class_name RespawnManager
extends Node
## Owns lives, failure handling and checkpoint activation.
##
## Failure (health 0 or falling) costs exactly one life, then the player returns
## to the active checkpoint with full health. At 0 lives `game_over` is emitted
## and progress is reset in place (no scene reload).
## Checkpoints activate when the player's X crosses the flag's X; the previous
## flag is removed and cannot activate again until the game-over reset.
## On a death that is not game over, enemies placed right of the respawn
## point's X are restored to their start; those at or left of it are left as
## they are; bonus heart items follow the same rule. On game over every enemy,
## every Burnable and every bonus heart is restored.
##
## Implements: design/game-brief.md (MVP 6, Player goal & fail state).
## Usage: place in the level and assign every reference below.

## Emitted when lives change (and once at start). `start_lives` is the maximum.
signal lives_changed(current: int, start_lives: int)
## Emitted when lives reach 0, before progress is reset.
signal game_over

## The player to respawn.
@export var player: Player
## Health and lives numbers (data-driven).
@export var stats: HealthStats
## Checkpoints in the level.
@export var checkpoints: Array[Checkpoint] = []
## Zones that count as failure when entered (pits).
@export var kill_zones: Array[KillZone] = []
## Enemies restored on death (only those placed right of the respawn X) and on
## game over (all).
@export var enemies: Array[Enemy] = []
## Burnable walls restored on game over.
@export var burnables: Array[Burnable] = []
## Bonus heart items restored on death (only those placed right of the respawn
## X) and on game over (all).
@export var bonus_hearts: Array[BonusHeart] = []

## Lives left.
var lives: int = 0

var _initial_position: Vector2
var _respawn_position: Vector2
var _active_checkpoint: Checkpoint = null
var _initialized: bool = false
## True while a failure is waiting for the deferred handler; further requests
## in the same frame are dropped so one failure is counted once.
var _fail_queued: bool = false


func _ready() -> void:
	assert(player != null, "RespawnManager: player is not assigned")
	assert(stats != null, "RespawnManager: stats is not assigned")
	assert(stats.max_health > 0, "RespawnManager: stats.max_health must be > 0")
	assert(stats.start_lives > 0, "RespawnManager: stats.start_lives must be > 0")
	# player.health is an @onready var on Player; wait for it if Player is
	# later in the tree than this node.
	if not player.is_node_ready():
		await player.ready
	_initial_position = player.global_position
	_respawn_position = _initial_position
	player.health.died.connect(_request_fail)
	for zone in kill_zones:
		zone.player_fell.connect(_request_fail)
	lives = stats.start_lives
	lives_changed.emit(lives, stats.start_lives)
	_initialized = true


func _physics_process(_delta: float) -> void:
	if not _initialized or _fail_queued:
		return
	_update_checkpoints()


## Activates the farthest unconsumed checkpoint the player's X has reached and
## consumes the rest (including the previously active one).
func _update_checkpoints() -> void:
	var player_x: float = player.global_position.x
	var crossed: Array[Checkpoint] = []
	for checkpoint in checkpoints:
		if not checkpoint.is_consumed() and player_x >= checkpoint.global_position.x:
			crossed.append(checkpoint)
	if crossed.is_empty():
		return
	var best: Checkpoint = crossed[0]
	for checkpoint in crossed:
		if checkpoint.global_position.x > best.global_position.x:
			best = checkpoint
	for checkpoint in crossed:
		if checkpoint != best:
			checkpoint.remove()
	if _active_checkpoint != null:
		_active_checkpoint.remove()
	_active_checkpoint = best
	best.activate()
	_respawn_position = best.global_position


## Queues one failure. Death and pit fall in the same frame count once; the
## respawn runs deferred, outside the physics callback that reported it.
func _request_fail() -> void:
	if _fail_queued:
		return
	_fail_queued = true
	_fail.call_deferred()


func _fail() -> void:
	_fail_queued = false
	lives -= 1
	lives_changed.emit(lives, stats.start_lives)
	if lives > 0:
		_reset_enemies_ahead_of(_respawn_position.x)
		_reset_bonus_hearts_ahead_of(_respawn_position.x)
		_place_player(_respawn_position)
		return
	game_over.emit()
	_reset_progress()


## Restores every enemy whose placed X is greater than `respawn_x`.
func _reset_enemies_ahead_of(respawn_x: float) -> void:
	for enemy in enemies:
		if enemy.get_start_position().x > respawn_x:
			enemy.reset_to_start()


## Restores every bonus heart whose placed X is greater than `respawn_x`.
func _reset_bonus_hearts_ahead_of(respawn_x: float) -> void:
	for heart in bonus_hearts:
		if heart.get_start_position().x > respawn_x:
			heart.reset()


func _reset_progress() -> void:
	_active_checkpoint = null
	_respawn_position = _initial_position
	for checkpoint in checkpoints:
		checkpoint.reset()
	for enemy in enemies:
		enemy.reset_to_start()
	for burnable in burnables:
		burnable.reset()
	for heart in bonus_hearts:
		heart.reset()
	lives = stats.start_lives
	_place_player(_respawn_position)
	lives_changed.emit(lives, stats.start_lives)


func _place_player(position: Vector2) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	player.ability_holder.clear()
	player.health.set_health(stats.max_health)
