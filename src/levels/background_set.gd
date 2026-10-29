class_name BackgroundSet
extends Resource
## One parallax background: its layers back to front with their scroll factors.
## Each layer repeats horizontally every texture width (the art is seamless).
##
## Implements: story-012, design/art/art-bible.md §6 (layers L0..L3:
## sky fixed, clouds 0.1 with slow drift, far 0.25, town 0.5).
## Usage: `assets/data/backgrounds/*.tres`, used by `LevelBackdrop`.

## Layer pictures, back (L0 sky) to front (L3 town).
@export var textures: Array[Texture2D] = []
## Horizontal scroll factor per layer (0 = fixed to the view, 1 = moves with
## the level). Same order as `textures`.
@export var scroll_factors: PackedFloat32Array = PackedFloat32Array()
## Constant drift per layer in pixels per second (negative = to the left).
## Same order as `textures`; a missing entry means no drift.
@export var drift_speeds: PackedFloat32Array = PackedFloat32Array()
## Y of the layers' top edge in level coordinates. The art is 320 px tall and
## drawn with its dock line at y 280, so 0 lines it up with the ground top.
@export var top_y: float = 0.0
