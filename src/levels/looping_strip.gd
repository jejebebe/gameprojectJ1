class_name LoopingStrip
extends AnimatedSprite2D
## Plays a horizontal sprite-sheet strip in a loop, built at runtime from data
## (goal flag, bonus heart). Presentation only: no gameplay state.
##
## Implements: story-012 (prop art), design/art/art-bible.md §6.
## Usage: put on an AnimatedSprite2D, set `sheet`, `frame_size`, `frame_count`
## and `fps` (frames per second = 1 / frame time).

## Horizontal strip of equally sized frames, read left to right.
@export var sheet: Texture2D
## Size of one frame.
@export var frame_size: Vector2i = Vector2i(24, 24)
## Number of frames in `sheet`.
@export var frame_count: int = 1
## Playback speed in frames per second.
@export var fps: float = 10.0


func _ready() -> void:
	assert(sheet != null, "LoopingStrip: sheet is not assigned")
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(frames, &"default", sheet, frame_size, frame_count, fps, true)
	sprite_frames = frames
	play(&"default")
