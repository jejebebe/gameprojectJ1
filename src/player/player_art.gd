class_name PlayerArt
extends Resource
## Jei's sprite data: frame size, per-animation timing and one strip folder per
## cape set. `build_frames` turns one set into a `SpriteFrames` at runtime.
## Change frame counts, speeds or folders here; no code change needed.
##
## Implements: story-010 (Jei sprite), design/art/art-bible.md §5.
## Usage: `Player.art` = `assets/data/player_art.tres`.

## Set id used when the player holds no ability (or one without its own set).
const DEFAULT_SET: StringName = &"default"

## Size of one frame in pixels (every strip of every set).
@export var frame_size: Vector2i = Vector2i(48, 52)
## Timing of each animation. Required names: idle, run, jump, fall, ability, hurt.
@export var animations: Array[PlayerAnimSpec] = []
## Strip folder per set id. Ability sets use the ability's `ability_id` as key;
## `&"default"` is the cape without an ability.
@export var set_folders: Dictionary[StringName, String] = {}
@export_group("Animation choice")
## Horizontal speed (pixels per second) above which a grounded player runs.
@export var run_speed_threshold: float = 1.0


## Builds the `SpriteFrames` of set `set_id` from `<folder>/<animation>.png`.
## Returns null (with an error) when the set id is unknown.
func build_frames(set_id: StringName) -> SpriteFrames:
	if not set_folders.has(set_id):
		push_error("PlayerArt: no folder for set '%s'" % set_id)
		return null
	var folder: String = set_folders[set_id]
	var frames := SpriteFrames.new()
	for spec in animations:
		var sheet := load("%s/%s.png" % [folder, spec.animation]) as Texture2D
		assert(sheet != null, "PlayerArt: missing strip %s/%s.png" % [folder, spec.animation])
		SheetFrames.add_strip(
			frames, spec.animation, sheet, frame_size, spec.frame_count, spec.fps, spec.loop
		)
	# Every new SpriteFrames starts with an empty "default" animation; drop it
	# unless the data defines one.
	if frames.has_animation(&"default") and frames.get_frame_count(&"default") == 0:
		frames.remove_animation(&"default")
	return frames
