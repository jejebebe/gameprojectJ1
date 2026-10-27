class_name Enemy
extends CharacterBody2D
## Base for all enemies: sprite-sheet animation, stomp vs contact decision and
## defeat. Subclasses implement `_behave` for their movement.
##
## Does not block the player physically (own collision layer); contact is read
## from the `HitArea` every physics frame, so damage repeats once the player's
## hit protection ends while still overlapping.
##
## Implements: design/game-brief.md (MVP 2), story-003.
## Usage: instance one of the enemy scenes and assign `stats`.

## Emitted once when the enemy is defeated (stomp or fireball).
signal defeated

## Numbers and sprite-sheet info (data-driven).
@export var stats: EnemyStats

## Horizontal patrol direction: 1.0 = right, -1.0 = left.
var _direction: float = 1.0
var _origin_x: float = 0.0
var _is_defeated: bool = false
var _defeat_tween: Tween
var _start_position: Vector2
var _start_direction: float
var _sprite_start_position: Vector2
var _sprite_start_scale: Vector2
var _sprite_start_modulate: Color

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _hit_area: Area2D = $HitArea
@onready var _body_shape: CollisionShape2D = $Shape


func _ready() -> void:
	assert(stats != null, "Enemy '%s' needs an EnemyStats resource in `stats`." % name)
	_origin_x = global_position.x
	_start_position = global_position
	_start_direction = _direction
	_sprite_start_position = _sprite.position
	_sprite_start_scale = _sprite.scale
	_sprite_start_modulate = _sprite.modulate
	var frames := SpriteFrames.new()
	frames.set_animation_speed(&"default", stats.fps)
	for i in stats.frame_count:
		var frame := AtlasTexture.new()
		frame.atlas = stats.sprite_sheet
		frame.region = Rect2(
			Vector2(stats.frame_size.x * i, 0), Vector2(stats.frame_size)
		)
		frames.add_frame(&"default", frame)
	_sprite.sprite_frames = frames
	_sprite.play(&"default")


func _physics_process(delta: float) -> void:
	if _is_defeated:
		return
	_behave(delta)
	for body: Node2D in _hit_area.get_overlapping_bodies():
		if body is Player:
			_resolve_contact(body as Player)
			break


## Moves the enemy for one physics frame. Overridden by each enemy type.
func _behave(_delta: float) -> void:
	pass


## Adds gravity while airborne.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += stats.gravity * delta


## Walks/flies along x over `travel_distance` around the placed position and
## turns around at both ends and at walls. Calls `move_and_slide`.
func _patrol_step() -> void:
	velocity.x = _direction * stats.move_speed
	move_and_slide()
	var offset := global_position.x - _origin_x
	var half := stats.travel_distance * 0.5
	if is_on_wall():
		# A corner can report a normal with x == 0; then just turn around.
		var normal_x := get_wall_normal().x
		_direction = signf(normal_x) if normal_x != 0.0 else -_direction
	elif offset >= half:
		_direction = -1.0
	elif offset <= -half:
		_direction = 1.0


## Stomp when the player falls (or was already bounced off another enemy this
## physics frame) and their feet are at or above the centre line (plus
## tolerance); otherwise contact damage.
func _resolve_contact(player: Player) -> void:
	var is_stomp := (
		player.is_stomp_falling()
		and player.get_feet_y() <= global_position.y + stats.stomp_tolerance
	)
	if is_stomp:
		defeat()
		player.bounce()
		if stats.granted_ability != null:
			player.ability_holder.acquire(stats.granted_ability)
	else:
		player.take_damage(stats.damage)


## True once `defeat` has run (also during the defeat fade, while the body
## still exists).
func is_defeated() -> bool:
	return _is_defeated


## Placed position recorded at `_ready` (the position `reset_to_start` restores).
func get_start_position() -> Vector2:
	return _start_position


## Restores the placed position and start state. Brings a defeated enemy back
## (visible, moving, collidable again); on a live enemy it just returns it to
## the start. Used by RespawnManager on death and game over (story-004).
func reset_to_start() -> void:
	if _defeat_tween != null and _defeat_tween.is_valid():
		_defeat_tween.kill()
	_defeat_tween = null
	_is_defeated = false
	global_position = _start_position
	velocity = Vector2.ZERO
	_direction = _start_direction
	_reset_behaviour()
	_sprite.position = _sprite_start_position
	_sprite.scale = _sprite_start_scale
	_sprite.modulate = _sprite_start_modulate
	_sprite.play(&"default")
	show()
	set_physics_process(true)
	_body_shape.set_deferred(&"disabled", false)
	_hit_area.set_deferred(&"monitoring", true)


## Resets subclass-specific behaviour state. Overridden by enemy types that
## keep timers or similar.
func _reset_behaviour() -> void:
	pass


## Hides the enemy and turns off its physics and collision, so a defeated
## enemy can neither touch the player nor be hit by a fireball.
func _deactivate() -> void:
	hide()
	set_physics_process(false)
	_body_shape.set_deferred(&"disabled", true)
	_hit_area.set_deferred(&"monitoring", false)


## Defeats the enemy (flatten and fade, then hidden and inactive until
## `reset_to_start`). Does nothing if it is already defeated. Grants no
## ability: only a stomp does (see `_resolve_contact`).
func defeat() -> void:
	if _is_defeated:
		return
	_is_defeated = true
	velocity = Vector2.ZERO
	_sprite.stop()
	defeated.emit()
	# Flatten toward the feet: move the sprite down as it shrinks so its bottom
	# edge stays on the ground.
	var half_height := stats.frame_size.y * 0.5
	_defeat_tween = create_tween().set_parallel()
	_defeat_tween.tween_property(
		_sprite, "scale:y", stats.defeat_squash_scale, stats.defeat_time
	)
	_defeat_tween.tween_property(
		_sprite, "position:y",
		_sprite.position.y + half_height * (1.0 - stats.defeat_squash_scale),
		stats.defeat_time
	)
	_defeat_tween.tween_property(_sprite, "modulate:a", 0.0, stats.defeat_time)
	_defeat_tween.chain().tween_callback(_deactivate)
