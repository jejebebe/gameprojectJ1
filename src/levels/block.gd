@tool
class_name Block
extends StaticBody2D
## Solid rectangular block for temporary level geometry (ground segments,
## platforms, cliffs, invisible end walls). One node per block: it builds its
## own collision shape and flat colour look, both centred on the node.
##
## The shape and look are internal children created in `_ready`, so they are
## not saved into the level scene. The script is `@tool` only so the block is
## visible and sized in the editor; it does no editor-only work (no
## `Engine.is_editor_hint()` branch is needed: the same code runs in both).
##
## Implements: story-005 (temporary flat blocks; final art and tilemaps come in
## full production), design/levels/level-layouts.md (Conventions).
## Usage: add a StaticBody2D with this script, set `position` to the block's
## centre, then `size` and `color`. Collision layer 1 (world).

## Width and height in pixels, centred on the node.
@export var size: Vector2 = Vector2(64.0, 40.0):
	set(value):
		size = value
		_apply()
## Flat placeholder colour.
@export var color: Color = Color(0.5, 0.5, 0.5, 1.0):
	set(value):
		color = value
		_apply()

var _shape: CollisionShape2D = null
var _look: ColorRect = null


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape, false, Node.INTERNAL_MODE_FRONT)
	_look = ColorRect.new()
	_look.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_look, false, Node.INTERNAL_MODE_FRONT)
	_apply()


## Pushes `size` and `color` to the shape and look (no-op before `_ready`).
func _apply() -> void:
	if _shape == null or _look == null:
		return
	(_shape.shape as RectangleShape2D).size = size
	_look.position = -size * 0.5
	_look.size = size
	_look.color = color
