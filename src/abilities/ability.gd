class_name Ability
extends Resource
## Base for every ability the player can hold. A data resource: one `.tres` file
## per ability in `assets/data/abilities/`. Subclasses add their own numbers and
## override `use` (on-press abilities) and/or `physics_update` (hold abilities).
## It holds no runtime state (the cooldown timer lives in `AbilityHolder`), so
## one resource can be shared by every enemy that grants it.
##
## Implements: design/game-brief.md (MVP 3), story-004.
## Usage: assign to `EnemyStats.granted_ability`; `AbilityHolder.use()` calls `use`
## and `AbilityHolder.physics_update()` calls `physics_update` every physics frame.

## Unique name of the ability, e.g. `&"fireball"`.
@export var ability_id: StringName = &""
## Seconds before the ability can be used again after a use.
@export var cooldown: float = 0.5

@export_group("HUD icon")
## Pixel pattern shown in the HUD, one string per row; "#" is a filled pixel.
@export var icon_pattern: PackedStringArray = []
## Colour of the HUD icon.
@export var icon_color: Color = Color.WHITE


## Runs the ability for `player` when the ability button is pressed. Returns true
## when the ability really ran (the cooldown starts and `ability_used` is emitted
## only then); false when it had no effect, e.g. a ground-only ability used in
## the air. Overridden by on-press abilities; hold abilities keep this default.
func use(_player: Player) -> bool:
	return false


## Called every physics frame while this ability is held, after the player's
## gravity and before `move_and_slide`. `held` is true while the ability button
## is down. Overridden by hold abilities (glide); default does nothing.
func physics_update(_player: Player, _delta: float, _held: bool) -> void:
	pass


## Called when the ability stops being held (replaced or cleared) so any hold
## effect ends at once. Overridden by abilities that have a hold effect.
func deactivate(_player: Player) -> void:
	pass
