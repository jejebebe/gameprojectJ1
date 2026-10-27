class_name HealthComponent
extends Node
## Integer health for one actor. Receives damage and reports changes; it does
## not decide what a death means (see RespawnManager).
##
## Implements: design/game-brief.md (MVP 6).
## Usage: add as a child, assign `stats`, call `take_damage(1)`.

## Emitted whenever `current` changes.
signal health_changed(current: int, max_health: int)
## Emitted once when health reaches 0. Re-armed by `set_health` with a value above 0.
signal died
## Emitted when hit protection starts (`true`) or ends (`false`).
signal protection_changed(active: bool)

## Health numbers (data-driven).
@export var stats: HealthStats

## Current health.
var current: int = 0

var _is_dead: bool = false
var _protection_left: float = 0.0


func _ready() -> void:
	set_physics_process(false)
	current = stats.max_health
	health_changed.emit(current, stats.max_health)


func _physics_process(delta: float) -> void:
	_protection_left -= delta
	if _protection_left <= 0.0:
		_end_protection()


## Reduces health by `amount` (never below 0). Emits `died` once on reaching 0.
## Ignored while already dead or hit-protected. A hit that leaves the actor
## alive starts the protection time (`stats.hit_protection_time`).
func take_damage(amount: int) -> void:
	if _is_dead or is_protected():
		return
	current = maxi(current - amount, 0)
	health_changed.emit(current, stats.max_health)
	if current == 0:
		_is_dead = true
		died.emit()
	elif amount > 0 and stats.hit_protection_time > 0.0:
		_protection_left = stats.hit_protection_time
		set_physics_process(true)
		protection_changed.emit(true)


## True while hit protection is running.
func is_protected() -> bool:
	return _protection_left > 0.0


## Adds bonus health (health above `stats.max_health`), capped so the bonus
## never exceeds `stats.max_bonus_hearts`. Returns true if anything was added;
## returns false and changes nothing when dead, `amount` <= 0 or already at the cap.
func add_bonus_health(amount: int) -> bool:
	if _is_dead or amount <= 0:
		return false
	var cap: int = stats.max_health + stats.max_bonus_hearts
	if current >= cap:
		return false
	current = mini(current + amount, cap)
	health_changed.emit(current, stats.max_health)
	return true


## Sets health directly, e.g. on respawn. Clears hit protection.
## A value above 0 clears the dead state.
func set_health(value: int) -> void:
	current = maxi(value, 0)
	_is_dead = current == 0
	_end_protection()
	health_changed.emit(current, stats.max_health)


func _end_protection() -> void:
	if not is_protected() and not is_physics_processing():
		return
	_protection_left = 0.0
	set_physics_process(false)
	protection_changed.emit(false)
