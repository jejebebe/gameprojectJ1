class_name FireballAbility
extends Ability
## Throws a fireball in the direction the player faces. The fireball defeats an
## enemy or burns a `Burnable` it touches, and vanishes on walls or at
## `max_distance`.
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: `assets/data/abilities/fireball.tres`.

## Scene of the projectile.
@export var fireball_scene: PackedScene
## Flight speed in pixels per second.
@export var speed: float = 240.0
## Flight distance in pixels before the fireball burns out.
@export var max_distance: float = 210.0

@export_group("Flight sprite sheet")
## Horizontal strip of frames, drawn facing right.
@export var fly_sheet: Texture2D
## Size of one frame in pixels.
@export var fly_frame_size: Vector2i = Vector2i(8, 8)
## Number of frames in the strip.
@export var fly_frame_count: int = 4
## Animation speed in frames per second.
@export var fly_fps: float = 12.0

@export_group("Burst sprite sheet")
## Horizontal strip of the impact animation (played once).
@export var burst_sheet: Texture2D
## Size of one frame in pixels.
@export var burst_frame_size: Vector2i = Vector2i(16, 16)
## Number of frames in the strip.
@export var burst_frame_count: int = 3
## Animation speed in frames per second.
@export var burst_fps: float = 14.0


## Spawns a fireball at the player's position, moving the way the player faces.
## Always runs, so it returns true.
func use(player: Player) -> bool:
	var fireball := fireball_scene.instantiate() as Fireball
	player.get_parent().add_child(fireball)
	fireball.launch(self, player.global_position, player.facing)
	return true
