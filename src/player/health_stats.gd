class_name HealthStats
extends Resource
## Tunable health and lives numbers. Edit `assets/data/health_stats.tres`
## instead of changing code.
##
## Implements: design/game-brief.md (MVP 6, Player goal & fail state).
## Usage: `@export var stats: HealthStats` on HealthComponent and RespawnManager.

## Health per life. The player starts and respawns with this much health.
@export var max_health: int = 3
## Lives the player starts with (and gets back after game over).
@export var start_lives: int = 3
## Health a bonus heart item gives.
@export var bonus_heart_amount: int = 1
## Most bonus health (health above `max_health`) the player can hold.
@export var max_bonus_hearts: int = 2
## Seconds after a health-costing hit during which further damage is ignored.
@export var hit_protection_time: float = 1.5
## Seconds for one fade step of the player's flashing while protected.
@export var flash_interval: float = 0.1
## Lowest opacity (0..1) of the player's flashing while protected.
@export var flash_alpha: float = 0.3
