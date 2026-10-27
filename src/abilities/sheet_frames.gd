class_name SheetFrames
extends RefCounted
## Small helper that turns a horizontal sprite-sheet strip into a `SpriteFrames`
## animation, so ability effects are built at runtime from data.
##
## Implements: design/game-brief.md (art direction: effects are sprite sheets).
## Usage: `SheetFrames.add_strip(frames, &"default", sheet, Vector2i(16, 16), 4, 12.0, true)`.

## Adds animation `animation` to `frames`, made of `frame_count` cells of
## `frame_size` read left to right from `sheet`. Creates the animation unless it
## exists (every new `SpriteFrames` already has `&"default"`).
static func add_strip(
	frames: SpriteFrames, animation: StringName, sheet: Texture2D,
	frame_size: Vector2i, frame_count: int, fps: float, is_loop: bool
) -> void:
	if not frames.has_animation(animation):
		frames.add_animation(animation)
	frames.set_animation_speed(animation, fps)
	frames.set_animation_loop(animation, is_loop)
	for i in frame_count:
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(Vector2(frame_size.x * i, 0), Vector2(frame_size))
		frames.add_frame(animation, frame)
