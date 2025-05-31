extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage.rpc_id(body.get_multiplayer_authority(),\
			1e10)
