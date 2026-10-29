class_name Checkpoint
extends Node2D
## A flag that marks a respawn point. The node's own position is where the
## player is put back. It has no collision: RespawnManager activates it when the
## player's X crosses the flag's X (airborne counts).
##
## A flag is consumed when it becomes active or when a later flag replaces it.
## A consumed flag is hidden and never activates again until `reset()`.
##
## Look: frame 0 of `sheet` while inactive; the looping `sparkle_sheet` strip
## while active (it replaces the sheet's still active frame, art-bible §6).
##
## Implements: design/game-brief.md (MVP 6), story-012 (art). Placement is
## decided in story 005.

const _INACTIVE: StringName = &"inactive"
const _ACTIVE: StringName = &"active"

## Two-frame strip: frame 0 inactive, frame 1 active (still).
@export var sheet: Texture2D
## Looping active strip shown while the flag is the active checkpoint.
@export var sparkle_sheet: Texture2D
## Size of one frame in both strips.
@export var frame_size: Vector2i = Vector2i(24, 48)
## Frames in `sparkle_sheet`.
@export var sparkle_frame_count: int = 4
## Playback speed of the sparkle strip.
@export var sparkle_fps: float = 1.0 / 0.12

var _consumed: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	assert(sheet != null and sparkle_sheet != null, "Checkpoint: art is not assigned")
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(frames, _INACTIVE, sheet, frame_size, 1, 1.0, false)
	SheetFrames.add_strip(
		frames, _ACTIVE, sparkle_sheet, frame_size, sparkle_frame_count, sparkle_fps, true
	)
	_sprite.sprite_frames = frames
	_show_active(_consumed and visible)


## True once this flag was activated or removed; it can no longer activate.
func is_consumed() -> bool:
	return _consumed


## Marks this flag as the active checkpoint. It stays visible and is consumed.
func activate() -> void:
	_consumed = true
	visible = true
	_show_active(true)


## Consumes this flag and hides it (a newer checkpoint replaced it, or it was
## crossed in the same frame as a farther one). It cannot activate again.
func remove() -> void:
	_consumed = true
	visible = false
	_show_active(false)


## Restores the flag: visible again, armed and drawn inactive. Used on game over.
func reset() -> void:
	_consumed = false
	visible = true
	_show_active(false)


func _show_active(is_active: bool) -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	_sprite.play(_ACTIVE if is_active else _INACTIVE)
