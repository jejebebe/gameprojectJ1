class_name EnemyStats
extends Resource
## Tunable numbers and sprite-sheet info for one enemy type. Edit the `.tres`
## files in `assets/data/enemies/` instead of changing code. Each enemy type
## reads only the fields that apply to it.
##
## Implements: design/game-brief.md (MVP 2), story-003.
## Usage: `@export var stats: EnemyStats` on an Enemy scene.

@export_group("Sprite sheet")
## Horizontal strip of animation frames. Replace the PNG to change the art.
@export var sprite_sheet: Texture2D
## Size of one frame in pixels.
@export var frame_size: Vector2i = Vector2i(16, 16)
## Number of frames in the strip.
@export var frame_count: int = 2
## Animation speed in frames per second.
@export var fps: float = 6.0
## True when the art is drawn facing left; the sprite is flipped to face right.
## (Where the sprite sits on the body is the `Sprite` node position in the scene,
## given for this drawn direction; it is mirrored on x when the sprite flips.)
@export var art_faces_left: bool = true

@export_group("Ability")
## Ability the player gets when stomping this enemy; empty = grants nothing.
@export var granted_ability: Ability

@export_group("Combat")
## Health the player loses on contact (not a stomp).
@export var damage: int = 1
## Seconds the defeat flatten/fade lasts before the enemy is removed.
@export var defeat_time: float = 0.3
## Vertical scale the sprite flattens to on defeat (1.0 = no squash).
@export var defeat_squash_scale: float = 0.2
## Pixels below the enemy's centre line at which the player's feet still count
## as a stomp. Absorbs the one-frame lag of area overlap reporting.
@export var stomp_tolerance: float = 9.0

@export_group("Movement")
## Horizontal speed in pixels per second (Walker, Flyer).
@export var move_speed: float = 60.0
## Total length of the horizontal path, centred on the placed position, in pixels (Walker, Flyer).
@export var travel_distance: float = 150.0
## Downward acceleration in pixels per second squared (Walker, Jumper).
@export var gravity: float = 1350.0
## Seconds between jumps (Jumper).
@export var jump_interval: float = 1.5
## Initial upward speed of a jump (negative is up) in pixels per second (Jumper).
@export var jump_velocity: float = -375.0
## Height of the vertical bob in pixels; 0 for a straight flight (Flyer).
@export var bob_amplitude: float = 0.0
## Speed of the vertical bob in radians per second (Flyer).
@export var bob_speed: float = 3.0
