class_name PlayerAnimSpec
extends Resource
## Timing of one of Jei's animations. The same spec is used for every cape set,
## so all sets must draw the same number of frames per animation.
##
## Implements: story-010 (Jei sprite), design/assets/specs/jei-assets.md.
## Usage: entries of `PlayerArt.animations` in `assets/data/player_art.tres`.

## Animation name; also the strip file name (`<name>.png`) in each set folder.
@export var animation: StringName = &"idle"
## Number of frames in the strip, read left to right.
@export var frame_count: int = 1
## Animation speed in frames per second (1000 / milliseconds per frame).
@export var fps: float = 10.0
## True = loops; false = plays once (used for one-shots: ability, hurt).
@export var loop: bool = true
