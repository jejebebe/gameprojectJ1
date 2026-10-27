class_name Player
extends CharacterBody2D
## Side-view player: left/right movement and variable-height jump.
## Reads the input actions `move_left`, `move_right`, `jump` and `ability`, so touch,
## mouse and keyboard all drive it the same way.
##
## Usage: instance `player.tscn`; tune numbers in `assets/data/player_stats.tres`.

## Movement numbers (data-driven).
@export var stats: PlayerStats

## Direction the player last moved in: 1.0 = right, -1.0 = left. Kept when the
## player stops. Example: `camera.position.x = player.facing * 60.0`.
var facing: float = 1.0

## Health of this player (child node `Health`).
@onready var health: HealthComponent = $Health

## The single ability the player holds (child node `AbilityHolder`).
@onready var ability_holder: AbilityHolder = $AbilityHolder

@onready var _shape: CollisionShape2D = $Shape
@onready var _look: ColorRect = $Look

var _flash_tween: Tween
## True while the current rise started from a real jump (only then may a jump
## release cut it short). Cleared by `bounce()` and on landing.
var _is_jump_rise: bool = false
## Physics frame of the last `bounce()`; -1 = never.
var _bounce_frame: int = -1


func _ready() -> void:
	health.protection_changed.connect(_on_protection_changed)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + stats.gravity * delta, stats.max_fall_speed)
	elif Input.is_action_just_pressed(&"jump"):
		velocity.y = stats.jump_velocity
		_is_jump_rise = true
	else:
		_is_jump_rise = false

	# Releasing jump early cuts a jump's rise short: the longer it is held, the
	# higher. A stomp bounce is never cut.
	if _is_jump_rise and Input.is_action_just_released(&"jump") and velocity.y < 0.0:
		velocity.y *= stats.jump_cut_factor
		_is_jump_rise = false

	if Input.is_action_just_pressed(&"ability"):
		ability_holder.use()
	# Hold abilities (glide) run after gravity and jump, right before the move, so
	# they can adjust this frame's velocity.
	ability_holder.physics_update(delta, Input.is_action_pressed(&"ability"))

	var axis := Input.get_axis(&"move_left", &"move_right")
	if axis != 0.0:
		facing = signf(axis)
	velocity.x = axis * stats.move_speed
	move_and_slide()


## Removes `amount` health. Entry point for hazards and enemies.
func take_damage(amount: int) -> void:
	health.take_damage(amount)


## Throws the player upward after a stomp (`stats.stomp_bounce_velocity`).
func bounce() -> void:
	velocity.y = stats.stomp_bounce_velocity
	_is_jump_rise = false
	_bounce_frame = Engine.get_physics_frames()


## Throws the player upward at `velocity_y` (negative is up) as an ability jump.
## Unlike a normal jump, releasing the jump button does not cut it short.
func launch(velocity_y: float) -> void:
	velocity.y = velocity_y
	_is_jump_rise = false


## True when contact from above should count as a stomp: the player is falling,
## or was already bounced off another enemy in this same physics frame (so two
## enemies stomped at once are both defeated, not one stomp and one hit).
func is_stomp_falling() -> bool:
	return velocity.y > 0.0 or _bounce_frame == Engine.get_physics_frames()


## World Y of the bottom edge of the player's body.
func get_feet_y() -> float:
	return _shape.global_position.y + (_shape.shape as RectangleShape2D).size.y * 0.5


func _on_protection_changed(active: bool) -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	_look.modulate.a = 1.0
	if active:
		_flash_tween = create_tween().set_loops()
		_flash_tween.tween_property(_look, "modulate:a", health.stats.flash_alpha, health.stats.flash_interval)
		_flash_tween.tween_property(_look, "modulate:a", 1.0, health.stats.flash_interval)
