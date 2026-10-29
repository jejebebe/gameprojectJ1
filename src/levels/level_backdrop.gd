class_name LevelBackdrop
extends Node2D
## Parallax background of a level, built at runtime from `BackgroundSet` data.
## Put it first in the level so it draws behind everything.
##
## Optionally a second set (`boss_background`) fades in while the player is at
## or right of `boss_switch_x` and fades back out when the player is left of it
## (e.g. respawned at an earlier checkpoint after game over).
##
## Implements: story-012, design/art/art-bible.md §6 (layers L0..L3).
## Usage: add to the level as its first child, assign `background`, and for a
## boss level also `boss_background`, `player` and `boss_switch_x`.

## Background of the course.
@export var background: BackgroundSet
## Background of the boss arena (optional).
@export var boss_background: BackgroundSet
## Player whose X selects the background (needed only with `boss_background`).
@export var player: Node2D
## Player X from which the boss background is shown.
@export var boss_switch_x: float = 0.0
## Seconds of the fade between the two backgrounds.
@export var fade_time: float = 0.6

var _course: Node2D = null
var _boss: Node2D = null


func _ready() -> void:
	assert(background != null, "LevelBackdrop: background is not assigned")
	_course = _build(background, &"Course")
	if boss_background != null:
		assert(player != null, "LevelBackdrop: player is needed for boss_background")
		_boss = _build(boss_background, &"Boss")
		_boss.modulate.a = 1.0 if _wants_boss() else 0.0
		_update_visibility()
	else:
		set_process(false)


func _process(delta: float) -> void:
	var target: float = 1.0 if _wants_boss() else 0.0
	var step: float = delta / fade_time if fade_time > 0.0 else 1.0
	_boss.modulate.a = move_toward(_boss.modulate.a, target, step)
	_update_visibility()


func _wants_boss() -> bool:
	return player.global_position.x >= boss_switch_x


## Skips drawing a stack that is fully covered or fully transparent.
func _update_visibility() -> void:
	_boss.visible = _boss.modulate.a > 0.0
	_course.visible = _boss.modulate.a < 1.0


## Builds one stack of Parallax2D layers (one per texture) under a new group.
func _build(data: BackgroundSet, group_name: StringName) -> Node2D:
	var group := Node2D.new()
	group.name = group_name
	add_child(group)
	for i in data.textures.size():
		var texture: Texture2D = data.textures[i]
		var factor: float = data.scroll_factors[i] if i < data.scroll_factors.size() else 1.0
		var drift: float = data.drift_speeds[i] if i < data.drift_speeds.size() else 0.0
		var layer := Parallax2D.new()
		layer.name = "Layer%d" % i
		layer.scroll_scale = Vector2(factor, 1.0)
		layer.repeat_size = Vector2(texture.get_width(), 0.0)
		layer.autoscroll = Vector2(drift, 0.0)
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.position = Vector2(0.0, data.top_y)
		layer.add_child(sprite)
		group.add_child(layer)
	return group
