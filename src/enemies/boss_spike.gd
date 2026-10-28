class_name BossSpike
extends Area2D
## One spike of the boss's spike rain. First only a shadow marker shows on the
## floor, then the spike falls (damaging the player once on touch), lands, stays
## a moment and removes itself.
##
## Collision: layer 0, mask 4 (player), like `spike.tscn`.
##
## Implements: design/game-brief.md (MVP 5), story-006.
## Usage: the Boss adds an instance, then calls `setup`.

enum Phase { SHADOW, FALLING, LANDED }

var _stats: BossStats
var _floor_y: float = 0.0
var _phase: Phase = Phase.SHADOW
var _time_left: float = 0.0
var _half_height: float = 10.0
var _has_hit: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _shadow: ColorRect = $Shadow
@onready var _shape: CollisionShape2D = $Shape


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = false
	_sprite.hide()


func _physics_process(delta: float) -> void:
	match _phase:
		Phase.SHADOW:
			_time_left -= delta
			if _time_left <= 0.0:
				_start_falling()
		Phase.FALLING:
			global_position.y += _stats.spike_fall_speed * delta
			if global_position.y >= _floor_y - _half_height:
				global_position.y = _floor_y - _half_height
				_phase = Phase.LANDED
				_time_left = _stats.spike_linger_time
				set_deferred(&"monitoring", false)
		Phase.LANDED:
			_time_left -= delta
			if _time_left <= 0.0:
				queue_free()


## Places the spike's shadow at `x` on the floor at `floor_y` (world pixels) and
## starts the countdown to the fall, using the numbers and strip of `stats`.
func setup(stats: BossStats, x: float, floor_y: float) -> void:
	assert(stats.spike_strip != null, "BossStats needs a `spike_strip`.")
	_stats = stats
	_floor_y = floor_y
	var strip := stats.spike_strip
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(
		frames, &"default", strip.sheet, strip.frame_size, strip.frame_count, strip.fps, strip.loop
	)
	_sprite.sprite_frames = frames
	_sprite.play(&"default")
	_half_height = strip.frame_size.y * 0.5
	(_shape.shape as RectangleShape2D).size = Vector2(strip.frame_size.x - 2, strip.frame_size.y - 2)
	global_position = Vector2(x, floor_y - _half_height - _stats.spike_fall_height)
	_shadow.global_position = Vector2(x - _shadow.size.x * 0.5, floor_y - _shadow.size.y)
	_phase = Phase.SHADOW
	_time_left = stats.spike_shadow_time


func _start_falling() -> void:
	_phase = Phase.FALLING
	_sprite.show()
	_shadow.hide()
	monitoring = true


func _on_body_entered(body: Node2D) -> void:
	if _has_hit or not body is Player:
		return
	_has_hit = true
	(body as Player).take_damage(_stats.spike_damage)
