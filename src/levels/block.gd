@tool
class_name Block
extends StaticBody2D
## Solid rectangular block of level geometry (ground segments, platforms,
## cliffs, the boss gate, invisible end walls). One node per block: it builds
## its own collision shape and a 9-slice tile look, both centred on the node.
##
## The shape and look are internal children created in `_ready`, so they are
## not saved into the level scene. The script is `@tool` only so the block is
## visible and sized in the editor; it does no editor-only work (no
## `Engine.is_editor_hint()` branch is needed: the same code runs in both).
##
## Implements: story-005 (block geometry), story-012 (tile art),
## design/art/art-bible.md §6 (terrain mapping: stone dock ground, teal-tile
## floating blocks, 72x72 9-slice sources with 8 px margins),
## design/levels/level-layouts.md (Conventions).
## Usage: add a StaticBody2D with this script, set `position` to the block's
## centre, then `size` and `style`. Collision layer 1 (world).

## Which art the block is drawn with. The collision is the same for every style.
enum Style {
	## Stone dock floor (the long floor pieces at the bottom of the level).
	GROUND,
	## Teal-tile block (floating platforms, steps and cliffs).
	BLOCK,
	## Boss-room gate: drawn `GATE_ART_WIDTH` wide, centred, over the full height.
	GATE,
	## No look (end walls outside the camera limits).
	HIDDEN,
}

## 9-slice sources per style (art-bible §6 / §8). Presentation data, not tuning.
const TEXTURES: Dictionary[Style, Texture2D] = {
	Style.GROUND: preload("res://assets/art/tiles/ground.png"),
	Style.BLOCK: preload("res://assets/art/tiles/block.png"),
	Style.GATE: preload("res://assets/art/props/gate.png"),
}
## Patch margins (left, top, right, bottom) in source pixels per style.
const MARGINS: Dictionary[Style, Vector4i] = {
	Style.GROUND: Vector4i(8, 8, 8, 8),
	Style.BLOCK: Vector4i(8, 8, 8, 8),
	Style.GATE: Vector4i(0, 12, 0, 12),
}

## Width and height in pixels, centred on the node.
@export var size: Vector2 = Vector2(64.0, 40.0):
	set(value):
		size = value
		_apply()
## Art of the block.
@export var style: Style = Style.BLOCK:
	set(value):
		style = value
		_apply()

var _shape: CollisionShape2D = null
var _look: NinePatchRect = null


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape, false, Node.INTERNAL_MODE_FRONT)
	_look = NinePatchRect.new()
	_look.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Centre tiles repeat pixel-exactly; a partial last tile is clipped.
	_look.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	_look.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	add_child(_look, false, Node.INTERNAL_MODE_FRONT)
	_apply()


## Pushes `size` and `style` to the shape and look (no-op before `_ready`).
func _apply() -> void:
	if _shape == null or _look == null:
		return
	(_shape.shape as RectangleShape2D).size = size
	_look.visible = style != Style.HIDDEN
	if style == Style.HIDDEN:
		return
	var texture: Texture2D = TEXTURES[style]
	var margins: Vector4i = MARGINS[style]
	_look.texture = texture
	_look.patch_margin_left = margins.x
	_look.patch_margin_top = margins.y
	_look.patch_margin_right = margins.z
	_look.patch_margin_bottom = margins.w
	var look_size: Vector2 = size
	if style == Style.GATE:
		# The gate art is wider than its collision; keep the art's own width.
		look_size.x = texture.get_width()
	_look.position = -look_size * 0.5
	_look.size = look_size
