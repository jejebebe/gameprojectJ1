class_name KillZone
extends Area2D
## Area below the level. Entering it counts as a failure (fell into a pit).
##
## Implements: design/game-brief.md (MVP 6).

## Emitted when the player enters this zone.
signal player_fell


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_fell.emit()
