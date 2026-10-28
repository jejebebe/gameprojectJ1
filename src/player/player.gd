class_name Player
extends CharacterBody2D
## Side-view player: left/right movement and variable-height jump.
## Reads the input actions `move_left`, `move_right`, `jump` and `ability`, so touch,
## mouse and keyboard all drive it the same way.
##
## Usage: instance `player.tscn`; tune numbers in `assets/data/player_stats.tres`
## and the sprite animations in `assets/data/player_art.tres`.
##
## Implements: story-001 (movement), story-010 (Jei sprite and animations).

## One-shot animation names (must exist in `art.animations`, with loop off).
const ANIM_HURT: StringName = &"hurt"
const ANIM_ABILITY: StringName = &"ability"
## Looping animation names chosen every physics frame.
const ANIM_IDLE: StringName = &"idle"
const ANIM_RUN: StringName = &"run"
const ANIM_JUMP: StringName = &"jump"
const ANIM_FALL: StringName = &"fall"

## Movement numbers (data-driven).
@export var stats: PlayerStats
## Sprite frame size, animation timing and cape-set folders (data-driven).
@export var art: PlayerArt

## Direction the player last moved in: 1.0 = right, -1.0 = left. Kept when the
## player stops. Example: `camera.position.x = player.facing * 60.0`.
var facing: float = 1.0

## Health of this player (child node `Health`).
@onready var health: HealthComponent = $Health

## The single ability the player holds (child node `AbilityHolder`).
@onready var ability_holder: AbilityHolder = $AbilityHolder

@onready var _shape: CollisionShape2D = $Shape
@onready var _sprite: AnimatedSprite2D = $Sprite

var _flash_tween: Tween
## SpriteFrames per cape-set id, built once in `_ready`.
var _set_frames: Dictionary[StringName, SpriteFrames] = {}
## One-shot animation now playing (hurt / ability), or &"" when none. While set,
## the per-frame choice does not replace it.
var _one_shot: StringName = &""
## True while the current rise started from a real jump (only then may a jump
## release cut it short). Cleared by `bounce()` and on landing.
var _is_jump_rise: bool = false
## Physics frame of the last `bounce()`; -1 = never.
var _bounce_frame: int = -1
## Horizontal speed forced by `knock_back` while `_knockback_left` > 0.
var _knockback_x: float = 0.0
var _knockback_left: float = 0.0


func _ready() -> void:
	health.protection_changed.connect(_on_protection_changed)
	assert(art != null, "Player needs a PlayerArt resource in `art`.")
	for set_id: StringName in art.set_folders:
		var frames := art.build_frames(set_id)
		if frames != null:
			_set_frames[set_id] = frames
	assert(_set_frames.has(PlayerArt.DEFAULT_SET), "PlayerArt needs a '%s' set." % PlayerArt.DEFAULT_SET)
	_sprite.sprite_frames = _set_frames[PlayerArt.DEFAULT_SET]
	_sprite.play(ANIM_IDLE)
	_sprite.animation_finished.connect(_on_animation_finished)
	ability_holder.ability_changed.connect(_on_ability_changed)
	ability_holder.ability_used.connect(_on_ability_used)


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
	if _knockback_left > 0.0:
		_knockback_left -= delta
		velocity.x = _knockback_x
	move_and_slide()
	_update_animation()


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
	_sprite.modulate.a = 1.0
	if active:
		# Protection starts only on a hit that leaves the player alive: play hurt once.
		_play_one_shot(ANIM_HURT)
		_flash_tween = create_tween().set_loops()
		_flash_tween.tween_property(_sprite, "modulate:a", health.stats.flash_alpha, health.stats.flash_interval)
		_flash_tween.tween_property(_sprite, "modulate:a", 1.0, health.stats.flash_interval)


## Picks this frame's animation: a running one-shot (hurt, ability) is left to
## finish; otherwise jump/fall in the air, run/idle on the ground. Also faces the
## sprite (the art faces right).
func _update_animation() -> void:
	_sprite.flip_h = facing < 0.0
	if _one_shot != &"":
		return
	var next: StringName
	if not is_on_floor():
		next = ANIM_JUMP if velocity.y < 0.0 else ANIM_FALL
	elif absf(velocity.x) > art.run_speed_threshold:
		next = ANIM_RUN
	else:
		next = ANIM_IDLE
	if _sprite.animation != next or not _sprite.is_playing():
		_sprite.play(next)


## Starts one-shot `animation` from its first frame. Hurt outranks ability: an
## ability use does not cut a hurt that is still playing.
func _play_one_shot(animation: StringName) -> void:
	if _one_shot == ANIM_HURT and animation != ANIM_HURT:
		return
	_one_shot = animation
	_sprite.play(animation)
	_sprite.set_frame_and_progress(0, 0.0)


func _on_animation_finished() -> void:
	if _sprite.animation == _one_shot:
		_one_shot = &""
		_update_animation()


func _on_ability_used() -> void:
	_play_one_shot(ANIM_ABILITY)


## Swaps to the cape set of `ability` (null or a set-less ability → default),
## keeping the current animation, frame and progress.
func _on_ability_changed(ability: Ability) -> void:
	var set_id: StringName = PlayerArt.DEFAULT_SET
	if ability != null and _set_frames.has(ability.ability_id):
		set_id = ability.ability_id
	var frames: SpriteFrames = _set_frames[set_id]
	if _sprite.sprite_frames == frames:
		return
	var animation := _sprite.animation
	var frame := _sprite.frame
	var progress := _sprite.frame_progress
	var was_playing := _sprite.is_playing()
	_sprite.sprite_frames = frames
	if not frames.has_animation(animation):
		_one_shot = &""
		_update_animation()
		return
	_sprite.play(animation)
	if not was_playing:
		_sprite.pause()
	if frame < frames.get_frame_count(animation):
		_sprite.set_frame_and_progress(frame, progress)


## Pushes the player sideways at `speed_x` (pixels per second, sign = direction)
## for `time` seconds, overriding left/right input meanwhile. Used by the boss
## so a stomp cannot chain into repeated stomps on the same spot.
func knock_back(speed_x: float, time: float) -> void:
	_knockback_x = speed_x
	_knockback_left = time
