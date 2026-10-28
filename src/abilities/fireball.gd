class_name Fireball
extends Area2D
## Fireball projectile: flies straight (no gravity), defeats the first enemy or
## burns the first `Burnable` it touches, and bursts on walls or at max distance.
## Never detects or hurts the player.
##
## Collision: layer 8 (projectile, nothing detects it), mask 3 (world + enemy
## bodies). A `Burnable` is a world body, so mask 1 covers it.
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: spawned by `FireballAbility.use`; do not place by hand.

var _ability: FireballAbility
var _direction: float = 1.0
var _travelled: float = 0.0
var _is_done: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _is_done:
		return
	var step := _ability.speed * delta
	global_position.x += _direction * step
	_travelled += step
	if _travelled >= _ability.max_distance:
		_burst()


## Starts the flight from `origin` toward `direction` (1.0 = right, -1.0 = left),
## using the numbers and sprite sheets of `ability`.
func launch(ability: FireballAbility, origin: Vector2, direction: float) -> void:
	assert(ability.fly_sheet != null, "FireballAbility needs a `fly_sheet`.")
	assert(ability.burst_sheet != null, "FireballAbility needs a `burst_sheet`.")
	assert(ability.fly_frame_count > 0, "FireballAbility `fly_frame_count` must be > 0.")
	assert(ability.burst_frame_count > 0, "FireballAbility `burst_frame_count` must be > 0.")
	_ability = ability
	_direction = direction
	global_position = origin
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(
		frames, &"default", ability.fly_sheet, ability.fly_frame_size,
		ability.fly_frame_count, ability.fly_fps, true
	)
	SheetFrames.add_strip(
		frames, &"burst", ability.burst_sheet, ability.burst_frame_size,
		ability.burst_frame_count, ability.burst_fps, false
	)
	_sprite.sprite_frames = frames
	_sprite.flip_h = direction < 0.0
	_sprite.play(&"default")


func _on_body_entered(body: Node2D) -> void:
	if _is_done:
		return
	if body is Enemy:
		var enemy := body as Enemy
		if enemy.is_defeated():
			# Still fading out: fly past instead of spending the fireball.
			return
		enemy.take_hit()
	elif body is Burnable:
		(body as Burnable).burn()
	_burst()


## Stops the flight and plays the impact animation, then removes the fireball.
func _burst() -> void:
	_is_done = true
	set_deferred(&"monitoring", false)
	_sprite.play(&"burst")
	_sprite.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
