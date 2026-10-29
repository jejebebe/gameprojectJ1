class_name HealthHud
extends Control
## Top bar of the game view: health as hearts (top-left), lives as an icon
## plus a number (top-right) and the held ability's icon below the lives (empty
## when nothing is held). Display only: it listens to the signals of the
## injected nodes and never changes health or lives.
##
## Hearts: `max_health` slots. Full hearts = min(current, max_health), the rest
## of the slots are empty. Health above `max_health` (bonus) adds up to
## `stats.max_bonus_hearts` extra hearts drawn with `heart_bonus_texture` after
## the base ones. Hearts and the life icon are textures (art bible §7: navy
## 2 px outline baked in, empty heart = same silhouette, hollow) drawn at an
## integer `icon_scale`; the ability icon is still drawn from the ability's
## pixel pattern.
##
## Implements: design/game-brief.md (MVP 6), story-008, story-012.
## Usage: instance `health_hud.tscn` under a CanvasLayer (so the camera does not
## move it) and assign `health`, `respawn_manager` and `ability_holder`.

## Source of `health_changed`.
@export var health: HealthComponent
## Source of `lives_changed`.
@export var respawn_manager: RespawnManager
## Source of `ability_changed`.
@export var ability_holder: AbilityHolder

@export_group("Hearts")
## Screen pixels per texture pixel for hearts and the life icon (integer keeps
## the art crisp). Example: 16x16 art at `icon_scale = 2` is 32x32 on screen.
@export var icon_scale: int = 2
## Gap in screen pixels between two hearts.
@export var heart_spacing: int = 4
## Distance in screen pixels from the top-left corner to the first heart.
@export var margin: Vector2i = Vector2i(8, 8)
@export var heart_full_texture: Texture2D
## Hollow heart drawn for an empty slot (differs by shape, not colour alone).
@export var heart_empty_texture: Texture2D
@export var heart_bonus_texture: Texture2D

@export_group("Ability")
## Screen pixels per pattern pixel of the ability icon pattern.
@export var pixel_size: int = 3
## Gap in screen pixels between the lives icon row and the ability icon below it.
@export var ability_icon_gap: int = 6

@export_group("Lives")
@export var life_icon_texture: Texture2D
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
	for i: int in _max_health + bonus:
		var texture: Texture2D = heart_full_texture
		if i >= _max_health:
			texture = heart_bonus_texture
		elif i >= full:
			texture = heart_empty_texture
		if texture == null:
			continue
		var heart_size: Vector2 = texture.get_size() * icon_scale
		var heart_x: float = margin.x + i * (heart_size.x + heart_spacing)
		draw_texture_rect(texture, Rect2(Vector2(heart_x, margin.y), heart_size), false)
	var life_height: float = 0.0
	if life_icon_texture != null:
		var life_size: Vector2 = life_icon_texture.get_size() * icon_scale
		life_height = life_size.y
		var life_x: float = _lives_label.position.x - life_icon_gap - life_size.x
		draw_texture_rect(life_icon_texture, Rect2(Vector2(life_x, margin.y), life_size), false)
	if _ability != null and not _ability.icon_pattern.is_empty():
		var ability_width: int = _ability.icon_pattern[0].length() * pixel_size
		var ability_top: float = margin.y + life_height + ability_icon_gap
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
