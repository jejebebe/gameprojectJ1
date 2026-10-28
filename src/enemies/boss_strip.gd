class_name BossStrip
extends Resource
## One sprite-sheet animation strip of the boss (or one of its effects).
## Replace the PNG in the `.tres` to change the art; no code change needed.
##
## Implements: design/game-brief.md (art direction: sprite sheets), story-006.
## Usage: entries of `BossStats.strips`, `BossStats.dust_strip`, `BossStats.spike_strip`.

## Animation name the boss plays (idle is the base `EnemyStats` sheet).
@export var animation: StringName = &"idle"
## Horizontal strip of frames.
@export var sheet: Texture2D
## Size of one frame in pixels.
@export var frame_size: Vector2i = Vector2i(32, 24)
## Number of frames in the strip.
@export var frame_count: int = 2
## Animation speed in frames per second.
@export var fps: float = 8.0
## True = loops; false = plays once and holds the last frame.
@export var loop: bool = true
