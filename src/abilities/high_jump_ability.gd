class_name HighJumpAbility
extends Ability
## Big jump from the ground: pressing the ability button while standing makes a
## jump `jump_height_multiplier` times as high as a normal jump. Does nothing in
## the air, so it can be used again only after landing. A dust burst plays at the
## feet. The big jump is never shortened by releasing the jump button.
##
## Jump height is v^2 / (2 * gravity), so for a height multiplier m the launch
## speed is the normal jump speed * sqrt(m). With jump_velocity -380, gravity 900
## and m = 1.8: normal 80 px, high jump about 144 px.
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: `assets/data/abilities/high_jump.tres`.

## Height of the big jump relative to a normal jump (1.8 = 1.8x as high).
@export var jump_height_multiplier: float = 1.8

@export_group("Dust sprite sheet")
## Horizontal strip of the dust burst (played once at the feet).
@export var dust_sheet: Texture2D
## Size of one frame in pixels.
@export var dust_frame_size: Vector2i = Vector2i(16, 16)
## Number of frames in the strip.
@export var dust_frame_count: int = 4
## Animation speed in frames per second.
@export var dust_fps: float = 16.0


## Launches the player upward and spawns the dust burst. Returns false (no
## effect) when the player is not on the floor.
func use(player: Player) -> bool:
	if not player.is_on_floor():
		return false
	player.launch(player.stats.jump_velocity * sqrt(jump_height_multiplier))
	_spawn_dust(player)
	return true


func _spawn_dust(player: Player) -> void:
	assert(dust_sheet != null, "HighJumpAbility needs a `dust_sheet`.")
	assert(dust_frame_count > 0, "HighJumpAbility `dust_frame_count` must be > 0.")
	var frames := SpriteFrames.new()
	SheetFrames.add_strip(
		frames, &"default", dust_sheet, dust_frame_size, dust_frame_count, dust_fps, false
	)
	var dust := AnimatedSprite2D.new()
	dust.sprite_frames = frames
	player.get_parent().add_child(dust)
	# Frame bottom sits on the feet.
	dust.global_position = Vector2(
		player.global_position.x, player.get_feet_y() - dust_frame_size.y * 0.5
	)
	dust.animation_finished.connect(dust.queue_free, CONNECT_ONE_SHOT)
	dust.play(&"default")
