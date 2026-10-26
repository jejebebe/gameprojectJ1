class_name CameraStats
extends Resource
## Tunable look-ahead numbers for the player camera. Edit
## `assets/data/camera_stats.tres` instead of changing code.
##
## Usage: `@export var stats: CameraStats` on the camera, then read
## `stats.look_ahead_distance`.

## How far ahead of the player, in pixels, the camera sits in the facing direction.
@export var look_ahead_distance: float = 60.0
## How fast, in pixels per second, the camera slides to the new side when facing flips.
@export var look_ahead_speed: float = 180.0
