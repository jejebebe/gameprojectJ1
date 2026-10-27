class_name GlideAbility
extends Ability
## Slow fall: while the player is in the air, falling, and the ability button is
## held, the fall speed is capped to `max_fall_speed`. Left/right movement is
## untouched and there is no time limit. Releasing the button, landing, or
## losing the ability ends it. A parachute effect (looping sprite sheet) is shown
## above the player only while gliding.
##
## The effect node (`GlideEffect`) is created lazily as a child of the player;
## this resource keeps no runtime state, so it is found again by name.
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: `assets/data/abilities/glide.tres`.

const EFFECT_NODE_NAME: StringName = &"GlideEffect"

## Fall speed cap while gliding, in pixels per second.
@export var max_fall_speed: float = 60.0

@export_group("Parachute sprite sheet")
## Horizontal strip of the looping parachute animation.
@export var effect_sheet: Texture2D
## Size of one frame in pixels.
@export var effect_frame_size: Vector2i = Vector2i(16, 16)
## Number of frames in the strip.
@export var effect_frame_count: int = 3
## Animation speed in frames per second.
@export var effect_fps: float = 8.0
## Position of the effect relative to the player's centre.
@export var effect_offset: Vector2 = Vector2(0, -22)


## Caps the fall speed while gliding and shows or hides the parachute.
func physics_update(player: Player, _delta: float, held: bool) -> void:
	var is_gliding := held and not player.is_on_floor() and player.velocity.y > max_fall_speed
	if is_gliding:
		player.velocity.y = max_fall_speed
	_set_effect_shown(player, is_gliding)


## Ends the glide effect at once.
func deactivate(player: Player) -> void:
	_set_effect_shown(player, false)


func _set_effect_shown(player: Player, is_shown: bool) -> void:
	var effect := player.get_node_or_null(NodePath(EFFECT_NODE_NAME)) as AnimatedSprite2D
	if effect == null:
		if not is_shown:
			return
		effect = _create_effect(player)
	effect.visible = is_shown
	if is_shown and not effect.is_playing():
		effect.play(&"default")


func _create_effect(player: Player) -> AnimatedSprite2D:
	assert(effect_sheet != null, "GlideAbility needs an `effect_sheet`.")
	assert(effect_frame_count > 0, "GlideAbility `effect_frame_count` must be > 0.")
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(
		frames, &"default", effect_sheet, effect_frame_size, effect_frame_count,
		effect_fps, true
	)
	var effect := AnimatedSprite2D.new()
	effect.name = EFFECT_NODE_NAME
	effect.sprite_frames = frames
	effect.position = effect_offset
	effect.visible = false
	player.add_child(effect)
	return effect
