class_name HealthHud
extends Control
## Top bar of the game view: health as hearts (top-left), lives as an icon
## plus a number (top-right) and the held ability's icon below the lives (empty
## when nothing is held). Display only: it listens to the signals of the
## injected nodes and never changes health or lives.
##
## Hearts: `max_health` slots. Full hearts = min(current, max_health), the rest
## of the slots are empty. Health above `max_health` (bonus) adds up to
## `stats.max_bonus_hearts` extra hearts in `bonus_color` after the base ones.
## Placeholder art is drawn from the pixel patterns below (real art: story 005).
##
## Implements: design/game-brief.md (MVP 6), story-008.
## Usage: instance `health_hud.tscn` under a CanvasLayer (so the camera does not
## move it) and assign `health`, `respawn_manager` and `ability_holder`.

## Pixel patterns, one string per row; "#" is a filled pixel.
const HEART_PATTERN: PackedStringArray = [
	".##.##.",
	"#######",
	"#######",
	".#####.",
	"..###..",
	"...#...",
]
## Border of `HEART_PATTERN` (same silhouette, hollow inside), used for empty
## slots so full and empty hearts differ by shape, not by colour alone.
const HEART_OUTLINE_PATTERN: PackedStringArray = [
	".##.##.",
	"#..#..#",
	"#.....#",
	".#...#.",
	"..#.#..",
	"...#...",
]
const LIFE_ICON_PATTERN: PackedStringArray = [
	"..###..",
	".#####.",
	"#######",
	"#######",
	".#####.",
	"..###..",
]

## Source of `health_changed`.
@export var health: HealthComponent
## Source of `lives_changed`.
@export var respawn_manager: RespawnManager
## Source of `ability_changed`.
@export var ability_holder: AbilityHolder

@export_group("Hearts")
## Screen pixels per pattern pixel (integer keeps the art crisp).
@export var pixel_size: int = 3
## Gap in screen pixels between two hearts.
@export var heart_spacing: int = 4
## Distance in screen pixels from the top-left corner to the first heart.
@export var margin: Vector2i = Vector2i(6, 4)
@export var full_color: Color = Color(0.9, 0.15, 0.2)
## Colour of the outline drawn for an empty heart slot.
@export var empty_color: Color = Color(0.85, 0.85, 0.9)
@export var bonus_color: Color = Color(0.2, 0.75, 1.0)

@export_group("Ability")
## Gap in screen pixels between the lives icon row and the ability icon below it.
@export var ability_icon_gap: int = 6

@export_group("Lives")
@export var life_icon_color: Color = Color(1.0, 0.8, 0.2)
## Gap in screen pixels between the life icon and the number.
@export var life_icon_gap: int = 4
## Format of the number text; receives the lives left.
@export var lives_format: String = "x %d"

var _current_health: int = 0
var _max_health: int = 0
## Ability shown in the HUD, or null.
var _ability: Ability = null

@onready var _lives_label: Label = $LivesLabel


func _ready() -> void:
	# Scene-wired sources (node_path exports) are bound at once; otherwise the
	# owner calls `bind` when the level is loaded.
	if health != null and respawn_manager != null and ability_holder != null:
		bind(health, respawn_manager, ability_holder)


## Switches the HUD to new sources (e.g. after a level change): disconnects the
## previous ones, connects `health_changed`, `lives_changed` and
## `ability_changed` of the new ones and refreshes the display at once.
## Call after this node and the new sources are ready.
func bind(
	new_health: HealthComponent,
	new_respawn_manager: RespawnManager,
	new_ability_holder: AbilityHolder
) -> void:
	assert(new_health != null, "HealthHud.bind: health is null")
	assert(new_respawn_manager != null, "HealthHud.bind: respawn_manager is null")
	assert(new_ability_holder != null, "HealthHud.bind: ability_holder is null")
	_disconnect_sources()
	health = new_health
	respawn_manager = new_respawn_manager
	ability_holder = new_ability_holder
	health.health_changed.connect(_on_health_changed)
	respawn_manager.lives_changed.connect(_on_lives_changed)
	ability_holder.ability_changed.connect(_on_ability_changed)
	# The level may have emitted its first values before the HUD was bound.
	_on_health_changed(health.current, health.stats.max_health)
	_on_lives_changed(respawn_manager.lives, respawn_manager.stats.start_lives)
	_on_ability_changed(ability_holder.current)


func _disconnect_sources() -> void:
	if is_instance_valid(health) and health.health_changed.is_connected(_on_health_changed):
		health.health_changed.disconnect(_on_health_changed)
	if (
		is_instance_valid(respawn_manager)
		and respawn_manager.lives_changed.is_connected(_on_lives_changed)
	):
		respawn_manager.lives_changed.disconnect(_on_lives_changed)
	if (
		is_instance_valid(ability_holder)
		and ability_holder.ability_changed.is_connected(_on_ability_changed)
	):
		ability_holder.ability_changed.disconnect(_on_ability_changed)


func _draw() -> void:
	if health == null:
		return
	var bonus: int = clampi(_current_health - _max_health, 0, health.stats.max_bonus_hearts)
	var full: int = mini(_current_health, _max_health)
	var heart_step: int = HEART_PATTERN[0].length() * pixel_size + heart_spacing
	for i: int in _max_health + bonus:
		var color: Color = full_color
		var pattern: PackedStringArray = HEART_PATTERN
		if i >= _max_health:
			color = bonus_color
		elif i >= full:
			color = empty_color
			pattern = HEART_OUTLINE_PATTERN
		_draw_pattern(pattern,Vector2(margin.x + i * heart_step, margin.y), color)
	var icon_width: int = LIFE_ICON_PATTERN[0].length() * pixel_size
	_draw_pattern(
		LIFE_ICON_PATTERN,
		Vector2(_lives_label.position.x - life_icon_gap - icon_width, margin.y),
		life_icon_color
	)
	if _ability != null and not _ability.icon_pattern.is_empty():
		var ability_width: int = _ability.icon_pattern[0].length() * pixel_size
		var ability_top: int = margin.y + LIFE_ICON_PATTERN.size() * pixel_size + ability_icon_gap
		_draw_pattern(
			_ability.icon_pattern,
			Vector2(size.x - margin.x - ability_width, ability_top),
			_ability.icon_color
		)


func _draw_pattern(pattern: PackedStringArray, origin: Vector2, color: Color) -> void:
	for row: int in pattern.size():
		for column: int in pattern[row].length():
			if pattern[row][column] == "#":
				var pixel_origin := origin + Vector2(column, row) * pixel_size
				draw_rect(Rect2(pixel_origin, Vector2(pixel_size, pixel_size)), color)


func _on_health_changed(current: int, max_health: int) -> void:
	_current_health = current
	_max_health = max_health
	queue_redraw()


func _on_ability_changed(ability: Ability) -> void:
	_ability = ability
	queue_redraw()


func _on_lives_changed(current: int, _start_lives: int) -> void:
	_lives_label.text = lives_format % current
	queue_redraw()
