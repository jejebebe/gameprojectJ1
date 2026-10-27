class_name Spike
extends Area2D
## Test hazard: damages the player once on entry. Enemy damage rules are story 003.
##
## Implements: design/game-brief.md (MVP 6).

## Health removed from the player on entry.
@export var damage: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).take_damage(damage)
