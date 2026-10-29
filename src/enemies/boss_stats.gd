class_name BossStats
extends EnemyStats
## Tunable numbers and sprite strips of the boss "가시 두더지". Edit
## `assets/data/enemies/boss_stats.tres` instead of changing code. The idle
## animation uses the base `EnemyStats` sprite fields; every other animation is
## an entry of `strips`.
##
## Implements: design/game-brief.md (MVP 5), story-006 (decided boss design,
## decision log 2026-10-28).
## Usage: `@export var stats: BossStats` on the Boss scene.

@export_group("Health")
## Hits the boss takes before it is defeated.
@export var max_hp: int = 3
## Seconds after a hit during which the boss flashes and cannot be hurt (and does
## not hurt the player by touch).
@export var hit_invulnerable_time: float = 1.5
## Seconds the boss reels (hurt animation, no attack) after a hit.
@export var hurt_time: float = 1.0
## Sideways speed (pixels per second) the player is pushed away at after
## stomping the boss, so one stomp cannot chain into the next hit.
@export var stomp_knockback_speed: float = 240.0
## How long (seconds) that push overrides the player's left/right input.
@export var stomp_knockback_time: float = 0.4
## Seconds between flash on/off while invulnerable.
@export var hit_flash_interval: float = 0.08
## Sprite alpha during the "off" part of the flash.
@export var hit_flash_alpha: float = 0.35

@export_group("Pattern flow")
## Pattern order, cycled in a fixed loop (deterministic): 0 = charge,
## 1 = jump slam, 2 = spike rain. Never the same pattern twice in a row as long
## as the list has no equal neighbours.
@export var pattern_order: Array[int] = [0, 1, 2]
## Seconds the boss idles between patterns (and when the fight starts).
@export var idle_time: float = 1.2
## Seconds of warning animation before every attack.
@export var telegraph_time: float = 1.0

@export_group("Charge")
## Pixels the boss steps back (away from the player) at the start of the telegraph.
@export var charge_step_back: float = 42.0
## Seconds the step back takes.
@export var charge_step_back_time: float = 0.3
## Rolling speed in pixels per second.
@export var charge_speed: float = 345.0
## Seconds the boss pauses after reaching the wall.
@export var charge_recover_time: float = 0.8

@export_group("Jump slam")
## Height of the leap arc in pixels.
@export var jump_height: float = 165.0
## Seconds the leap lasts, take-off to landing.
@export var jump_time: float = 0.8
## Seconds the boss is dazed after landing (the player's chance to stomp it).
@export var daze_time: float = 2.0

@export_group("Spike rain")
## Number of spikes that fall.
@export var spike_count: int = 3
## Horizontal distance between neighbouring spikes in pixels (centred on the player).
@export var spike_spacing: float = 84.0
## Seconds the shadow markers show before the spikes start to fall.
@export var spike_shadow_time: float = 0.8
## Height above the floor the spikes start falling from, in pixels.
@export var spike_fall_height: float = 300.0
## Fall speed in pixels per second.
@export var spike_fall_speed: float = 390.0
## Health the player loses when a spike hits.
@export var spike_damage: int = 1
## Seconds a landed spike stays before it is removed.
@export var spike_linger_time: float = 0.25
## Seconds the boss pauses after the spikes have landed.
@export var rain_recover_time: float = 0.6

@export_group("Defeat")
## Seconds the clear message shows before the level completes.
@export var clear_message_time: float = 2.0

@export_group("Animation strips")
## Strips for the animations `shake`, `crouch`, `puff`, `roll`, `jump`, `dazed`
## and `hurt` (idle is the base sprite sheet).
@export var strips: Array[BossStrip] = []
## Landing dust effect strip.
@export var dust_strip: BossStrip
## Falling spike strip.
@export var spike_strip: BossStrip
