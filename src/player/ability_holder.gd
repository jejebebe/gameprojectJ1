class_name AbilityHolder
extends Node
## Holds at most one ability for the player. A new ability replaces the old one.
## Runs the ability on `use()` when its cooldown has ended.
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: child of the Player scene; `player` is assigned in the scene.

## Emitted when the held ability changes; `ability` is null when emptied.
signal ability_changed(ability: Ability)
## Emitted each time the held ability actually runs.
signal ability_used

## The player passed to the ability when it runs.
@export var player: Player

## The held ability, or null.
var current: Ability = null

var _cooldown_left: float = 0.0


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)


## Takes `ability`, replacing any held one. The new ability is ready at once.
func acquire(ability: Ability) -> void:
	if current != null:
		current.deactivate(player)
	current = ability
	_cooldown_left = 0.0
	ability_changed.emit(current)


## Drops the held ability, if any.
func clear() -> void:
	if current == null:
		return
	current.deactivate(player)
	current = null
	ability_changed.emit(null)


## Runs the held ability's on-press action if there is one and its cooldown has
## ended. The cooldown starts and `ability_used` is emitted only when the ability
## reports that it really ran (see `Ability.use`).
func use() -> void:
	if current == null or _cooldown_left > 0.0:
		return
	if not current.use(player):
		return
	_cooldown_left = current.cooldown
	ability_used.emit()


## Gives the held ability its per-frame hold update (see `Ability.physics_update`).
## Called by the player each physics frame; `held` is whether the ability button
## is down.
func physics_update(delta: float, held: bool) -> void:
	if current != null:
		current.physics_update(player, delta, held)
