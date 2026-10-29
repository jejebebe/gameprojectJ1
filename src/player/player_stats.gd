class_name PlayerStats
extends Resource
## Tunable movement numbers for the player. Edit `assets/data/player_stats.tres`
## instead of changing code.
##
## Usage: `@export var stats: PlayerStats` on the player, then read `stats.move_speed`.

## Horizontal speed in pixels per second.
@export var move_speed: float = 180.0
## Initial upward speed of a jump (negative is up) in pixels per second.
@export var jump_velocity: float = -570.0
## Downward acceleration in pixels per second squared.
@export var gravity: float = 1350.0
## Maximum falling speed in pixels per second.
@export var max_fall_speed: float = 600.0
## Upward speed is multiplied by this when jump is released early (0 to 1).
@export_range(0.0, 1.0) var jump_cut_factor: float = 0.4
## Upward speed (negative is up) after stomping an enemy, in pixels per second.
@export var stomp_bounce_velocity: float = -300.0
