class_name CameraStats
extends Resource
## Tunable look-ahead numbers for the player camera. Edit
## `assets/data/camera_stats.tres` instead of changing code.
##
## Usage: `@export var stats: CameraStats` on the camera, then read
## `stats.look_ahead_distance`.

## How far ahead of the player, in pixels, the camera sits in the facing direction.
@export var look_ahead_distance: float = 90.0
## How fast, in pixels per second, the camera slides to the new side when facing flips.
@export var look_ahead_speed: float = 270.0
## While the camera has a focus (the boss in the boss fight): how far from the
## player toward the focus the camera aims (0 = on the player, 0.5 = midpoint,
## 1 = on the focus).
@export_range(0.0, 1.0) var focus_weight: float = 0.5
## While the camera has a focus: the player always stays at least this many
## pixels inside the view edge. When the player and the focus are farther apart
## than the view can show, the player wins and the focus may leave the view.
@export var focus_player_margin: float = 36.0
