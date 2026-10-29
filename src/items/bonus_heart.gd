class_name BonusHeart
extends Area2D
## Pickup that gives the player one bonus health (a bonus heart). The amount and
## the cap come from `HealthStats` (`bonus_heart_amount`, `max_bonus_hearts`).
## When the player is already at the bonus cap the item is NOT consumed and
## stays where it is; it is picked up as soon as the player drops below the cap
## while touching it. A picked-up item is hidden, not freed, so `reset()` can
## bring it back (RespawnManager calls it on death / game over).
##
## Look: the looping `Sprite` strip (story-012, art-bible §6).
##
## Implements: design/game-brief.md (MVP 6), story-009, story-012 (art).
## Usage: instance `bonus_heart.tscn` into the level and list it in
## `RespawnManager.bonus_hearts`.

var _start_position: Vector2
var _collected: bool = false


func _ready() -> void:
	_start_position = global_position


func _physics_process(_delta: float) -> void:
	if _collected:
		return
	for body: Node2D in get_overlapping_bodies():
		if body is Player:
			var player: Player = body
			var amount: int = player.health.stats.bonus_heart_amount
			if player.health.add_bonus_health(amount):
				_collect()
			return


## Position the item was placed at (used by RespawnManager to decide which
## items are ahead of the respawn point).
func get_start_position() -> Vector2:
	return _start_position


## True while the item has been picked up and not restored.
func is_collected() -> bool:
	return _collected


## Brings the item back at its original position. Safe on an uncollected item.
func reset() -> void:
	_collected = false
	global_position = _start_position
	show()
	set_deferred(&"monitoring", true)


func _collect() -> void:
	_collected = true
	hide()
	set_deferred(&"monitoring", false)
