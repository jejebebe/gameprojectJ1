class_name Burnable
extends StaticBody2D
## Wall that blocks the player and enemies until a fireball burns it. After
## `burn()` its collision is removed at once, the burn strip plays once, then
## the wall is hidden. `reset()` brings it back (RespawnManager calls it on game
## over).
##
## Look: `wall_texture` while intact, the `burn_sheet` strip while burning
## (art-bible §6 "불타는 나무벽").
##
## Implements: design/game-brief.md (MVP 3), story-004, story-012 (art).
## Usage: instance `burnable.tscn` into the level.

const _IDLE: StringName = &"idle"
const _BURN: StringName = &"burn"

## Still picture of the intact wall (one frame of `frame_size`).
@export var wall_texture: Texture2D
## Horizontal strip played once when the wall burns.
@export var burn_sheet: Texture2D
## Size of one frame of the wall and of the burn strip.
@export var frame_size: Vector2i = Vector2i(24, 96)
## Frames in `burn_sheet`.
@export var burn_frame_count: int = 6
## Playback speed of the burn strip (frames per second = 1 / frame time).
@export var burn_fps: float = 1.0 / 0.09

var _is_burning: bool = false

@onready var _shape: CollisionShape2D = $Shape
@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	assert(wall_texture != null and burn_sheet != null, "Burnable: art is not assigned")
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(frames, _IDLE, wall_texture, frame_size, 1, 1.0, false)
	SheetFrames.add_strip(frames, _BURN, burn_sheet, frame_size, burn_frame_count, burn_fps, false)
	_sprite.sprite_frames = frames
	_sprite.animation_finished.connect(_on_animation_finished)
	_sprite.play(_IDLE)


## Burns the wall away. Does nothing if it is already burning.
func burn() -> void:
	if _is_burning:
		return
	_is_burning = true
	_shape.set_deferred(&"disabled", true)
	_sprite.play(_BURN)


## Restores the wall (look and collision), also mid-burn. Safe on an intact wall.
func reset() -> void:
	_is_burning = false
	_sprite.play(_IDLE)
	show()
	_shape.set_deferred(&"disabled", false)


func _on_animation_finished() -> void:
	if _is_burning and _sprite.animation == _BURN:
		hide()
