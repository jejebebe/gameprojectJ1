class_name Boss
extends Enemy
## Level 3 boss "가시 두더지" (placeholder look). Stays dormant until the arena
## starts the fight, then cycles three attacks, each with a telegraph first:
## charge (steps back and shakes, then rolls to the wall; jump over it), jump
## slam (crouches, leaps to where the player stood, then is dazed: stomp chance)
## and spike rain (puffs up, shadows show, 3 spikes fall).
##
## Hits: a stomp or a fireball calls `take_hit` and costs 1 HP; the boss then
## flashes, reels and is invulnerable (and harmless by touch) for a while.
## `defeat()` is routed to `take_hit` so nothing kills it in one blow. At 0 HP it
## plays the normal defeat fade and emits `defeated`.
##
## State machine (`TRANSITIONS`): WAITING -> IDLE -> TELEGRAPH -> ATTACK ->
## RECOVER or DAZED -> IDLE; any alive state -> HURT -> IDLE; any alive state ->
## DEAD. Pattern order is a fixed cycle through `stats.pattern_order`.
##
## Respawn: `reset_to_start` (called by RespawnManager) restores full HP, the
## start position and IDLE (WAITING if the fight never started). All numbers
## come from `BossStats`.
##
## Implements: design/game-brief.md (MVP 5), story-006.
## Usage: instance `boss.tscn`, assign `player`, the arena X limits, and add it
## to `RespawnManager.enemies`; a BossArena starts the fight.

## Emitted after `reset_to_start` has restored the boss.
signal restored

## The attack patterns (values match `BossStats.pattern_order`).
enum Pattern { CHARGE, JUMP_SLAM, SPIKE_RAIN }
## Boss states.
enum State { WAITING, IDLE, TELEGRAPH, ATTACK, RECOVER, DAZED, HURT, DEAD }

## Allowed state changes (reset bypasses this table).
const TRANSITIONS: Dictionary = {
	State.WAITING: [State.IDLE],
	State.IDLE: [State.TELEGRAPH, State.HURT, State.DEAD],
	State.TELEGRAPH: [State.ATTACK, State.HURT, State.DEAD],
	State.ATTACK: [State.RECOVER, State.DAZED, State.HURT, State.DEAD],
	State.RECOVER: [State.IDLE, State.HURT, State.DEAD],
	State.DAZED: [State.IDLE, State.HURT, State.DEAD],
	State.HURT: [State.IDLE, State.DEAD],
	State.DEAD: [],
}
## Telegraph animation of each pattern.
const TELEGRAPH_ANIMATIONS: Dictionary = {
	Pattern.CHARGE: &"shake",
	Pattern.JUMP_SLAM: &"crouch",
	Pattern.SPIKE_RAIN: &"puff",
}
## Animations that `stats.strips` must provide.
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"shake", &"crouch", &"puff", &"roll", &"jump", &"dazed", &"hurt"
]

## The player the boss faces and aims at.
@export var player: Player
## Lowest centre X the boss may move to (arena left wall plus half its width).
@export var arena_left_x: float = 0.0
## Highest centre X the boss may move to (arena right wall minus half its width).
@export var arena_right_x: float = 0.0
## Scene of one falling spike (`boss_spike.tscn`).
@export var spike_scene: PackedScene

var _state: State = State.WAITING
var _state_time: float = 0.0
var _hp: int = 0
var _invulnerable_left: float = 0.0
var _pattern: Pattern = Pattern.CHARGE
var _pattern_index: int = 0
var _fight_started: bool = false
var _floor_y: float = 0.0
var _recover_time: float = 0.0
var _attack_time: float = 0.0
var _charge_direction: float = -1.0
var _jump_from_x: float = 0.0
var _jump_to_x: float = 0.0
var _spikes: Array[BossSpike] = []

@onready var _dust: AnimatedSprite2D = $Dust


func _ready() -> void:
	super()
	assert(stats is BossStats, "Boss '%s' needs a BossStats resource in `stats`." % name)
	assert(player != null, "Boss '%s': player is not assigned" % name)
	assert(spike_scene != null, "Boss '%s': spike_scene is not assigned" % name)
	assert(arena_left_x < arena_right_x, "Boss '%s': arena limits are not set" % name)
	var boss_stats := stats as BossStats
	assert(boss_stats.max_hp > 0, "BossStats.max_hp must be > 0")
	assert(not boss_stats.pattern_order.is_empty(), "BossStats.pattern_order is empty")
	var frames := _sprite.sprite_frames
	for strip in boss_stats.strips:
		SheetFrames.add_strip(
			frames, strip.animation, strip.sheet, strip.frame_size,
			strip.frame_count, strip.fps, strip.loop
		)
	for animation in REQUIRED_ANIMATIONS:
		assert(frames.has_animation(animation), "BossStats.strips lacks '%s'" % animation)
	assert(boss_stats.dust_strip != null, "BossStats needs a `dust_strip`.")
	var dust_frames := SpriteFrames.new()
	var dust := boss_stats.dust_strip
	SheetFrames.add_strip(
		dust_frames, &"dust", dust.sheet, dust.frame_size, dust.frame_count, dust.fps, false
	)
	_dust.sprite_frames = dust_frames
	_dust.animation_finished.connect(_dust.hide)
	_dust.hide()
	_floor_y = global_position.y + (_body_shape.shape as RectangleShape2D).size.y * 0.5
	_hp = boss_stats.max_hp


## Starts (or resumes after a respawn) the fight: the boss leaves WAITING.
func start_fight() -> void:
	_fight_started = true
	if _state == State.WAITING:
		_enter(State.IDLE)


## Marks the fight as not started; the next reset leaves the boss WAITING.
func stop_fight() -> void:
	_fight_started = false


## A stomp or fireball hit: costs 1 HP unless the boss is dormant, invulnerable
## or already defeated. Interrupts the current pattern. At 0 HP the boss dies.
func take_hit() -> void:
	if _is_defeated or _state == State.WAITING or _state == State.DEAD:
		return
	if _invulnerable_left > 0.0:
		return
	_hp -= 1
	global_position.y = _start_position.y
	if _hp <= 0:
		_die()
		return
	_invulnerable_left = _boss_stats().hit_invulnerable_time
	_enter(State.HURT)


## Never kills outright: routed to `take_hit`.
func defeat() -> void:
	take_hit()


## Current state (for the arena and debugging).
func get_state() -> State:
	return _state


## Current hit points.
func get_hp() -> int:
	return _hp


func _behave(delta: float) -> void:
	_state_time += delta
	_update_invulnerability(delta)
	var s := _boss_stats()
	match _state:
		State.IDLE:
			_face(_direction_to_player())
			if _state_time >= s.idle_time:
				_begin_telegraph()
		State.TELEGRAPH:
			_tick_telegraph(delta)
		State.ATTACK:
			_tick_attack(delta)
		State.RECOVER:
			if _state_time >= _recover_time:
				_enter(State.IDLE)
		State.DAZED:
			if _state_time >= s.daze_time:
				_enter(State.IDLE)
		State.HURT:
			if _state_time >= s.hurt_time:
				_enter(State.IDLE)
		_:
			pass


## While flashing after a hit the boss does not hurt the player by touch; a
## player falling onto it still bounces, so the stomp's own bounce is not
## punished on the next frame.
func _resolve_contact(contact_player: Player) -> void:
	var is_stomp := (
		contact_player.is_stomp_falling()
		and contact_player.get_feet_y() <= global_position.y + stats.stomp_tolerance
	)
	if _invulnerable_left > 0.0:
		if is_stomp:
			contact_player.bounce()
			_knock_away(contact_player)
		return
	super(contact_player)
	if is_stomp:
		_knock_away(contact_player)


## Pushes the player off the boss sideways (away from its centre; toward the
## arena middle when exactly on top) so the bounce does not land on it again.
func _knock_away(contact_player: Player) -> void:
	var direction := signf(contact_player.global_position.x - global_position.x)
	if direction == 0.0:
		direction = signf((arena_left_x + arena_right_x) * 0.5 - global_position.x)
		if direction == 0.0:
			direction = 1.0
	var s := _boss_stats()
	contact_player.knock_back(direction * s.stomp_knockback_speed, s.stomp_knockback_time)


func _reset_behaviour() -> void:
	_clear_spikes()
	_hp = _boss_stats().max_hp
	_invulnerable_left = 0.0
	_pattern_index = 0
	_state_time = 0.0
	_state = State.IDLE if _fight_started else State.WAITING
	_dust.hide()


func reset_to_start() -> void:
	super()
	restored.emit()


func _boss_stats() -> BossStats:
	return stats as BossStats


func _enter(new_state: State) -> void:
	if not new_state in TRANSITIONS[_state]:
		push_error("Boss: illegal transition %s -> %s" % [State.keys()[_state], State.keys()[new_state]])
		return
	_state = new_state
	_state_time = 0.0
	match new_state:
		State.IDLE, State.RECOVER:
			_sprite.play(&"default")
		State.DAZED:
			_sprite.play(&"dazed")
		State.HURT:
			_sprite.play(&"hurt")
		_:
			pass


func _update_invulnerability(delta: float) -> void:
	if _invulnerable_left <= 0.0:
		return
	_invulnerable_left -= delta
	if _invulnerable_left <= 0.0:
		_sprite.modulate = _sprite_start_modulate
		return
	var is_dim := int(_invulnerable_left / _boss_stats().hit_flash_interval) % 2 == 0
	_sprite.modulate.a = (
		_boss_stats().hit_flash_alpha if is_dim else _sprite_start_modulate.a
	)


func _die() -> void:
	_enter(State.DEAD)
	_clear_spikes()
	_dust.hide()
	_sprite.modulate = _sprite_start_modulate
	super.defeat()


func _direction_to_player() -> float:
	var d := signf(player.global_position.x - global_position.x)
	return d if d != 0.0 else -1.0


## Faces left (toward the arena entrance) when placed and after a reset;
## `Enemy._face` handles the flip from `stats.art_faces_left`.
func _start_facing() -> float:
	return Vector2.LEFT.x


func _next_pattern() -> Pattern:
	var order := _boss_stats().pattern_order
	var value: int = order[_pattern_index % order.size()]
	_pattern_index += 1
	return value as Pattern


func _begin_telegraph() -> void:
	_pattern = _next_pattern()
	_enter(State.TELEGRAPH)
	_sprite.play(TELEGRAPH_ANIMATIONS[_pattern])
	_charge_direction = _direction_to_player()
	_face(_charge_direction)


func _tick_telegraph(delta: float) -> void:
	var s := _boss_stats()
	if _pattern == Pattern.CHARGE and _state_time < s.charge_step_back_time:
		var step := s.charge_step_back / s.charge_step_back_time * delta
		global_position.x = clampf(
			global_position.x - _charge_direction * step, arena_left_x, arena_right_x
		)
	if _state_time >= s.telegraph_time:
		_begin_attack()


func _begin_attack() -> void:
	var s := _boss_stats()
	_enter(State.ATTACK)
	match _pattern:
		Pattern.CHARGE:
			_sprite.play(&"roll")
		Pattern.JUMP_SLAM:
			_sprite.play(&"jump")
			_jump_from_x = global_position.x
			_jump_to_x = clampf(player.global_position.x, arena_left_x, arena_right_x)
			_face(signf(_jump_to_x - _jump_from_x))
		Pattern.SPIKE_RAIN:
			_spawn_spikes()
			_attack_time = (
				s.spike_shadow_time + s.spike_fall_height / s.spike_fall_speed + s.spike_linger_time
			)


func _tick_attack(delta: float) -> void:
	var s := _boss_stats()
	match _pattern:
		Pattern.CHARGE:
			var target_x := arena_left_x if _charge_direction < 0.0 else arena_right_x
			global_position.x = move_toward(global_position.x, target_x, s.charge_speed * delta)
			if is_equal_approx(global_position.x, target_x):
				_recover_time = s.charge_recover_time
				_enter(State.RECOVER)
		Pattern.JUMP_SLAM:
			var u := clampf(_state_time / s.jump_time, 0.0, 1.0)
			global_position.x = lerpf(_jump_from_x, _jump_to_x, u)
			global_position.y = _start_position.y - 4.0 * s.jump_height * u * (1.0 - u)
			if u >= 1.0:
				global_position.y = _start_position.y
				_play_landing_dust()
				_enter(State.DAZED)
		Pattern.SPIKE_RAIN:
			if _state_time >= _attack_time:
				_recover_time = s.rain_recover_time
				_enter(State.RECOVER)


func _play_landing_dust() -> void:
	var frame_height := _boss_stats().dust_strip.frame_size.y
	_dust.global_position = Vector2(global_position.x, _floor_y - frame_height * 0.5)
	_dust.show()
	_dust.play(&"dust")


func _spawn_spikes() -> void:
	var s := _boss_stats()
	var level := get_parent()
	for i in s.spike_count:
		var offset := (i - (s.spike_count - 1) * 0.5) * s.spike_spacing
		var x := clampf(player.global_position.x + offset, arena_left_x, arena_right_x)
		var spike := spike_scene.instantiate() as BossSpike
		level.add_child(spike)
		spike.setup(s, x, _floor_y)
		_spikes.append(spike)
		# Spikes free themselves after landing: drop them from the list then.
		spike.tree_exiting.connect(_spikes.erase.bind(spike))


func _clear_spikes() -> void:
	for spike: Variant in _spikes.duplicate():
		if is_instance_valid(spike):
			spike.queue_free()
	_spikes.clear()
