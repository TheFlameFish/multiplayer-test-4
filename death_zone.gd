extends Area2D


func _on_body_entered(body: Node2D) -> void:
	# The authority check doesn't really matter here since we're
	# dealing 100 billion dmg, but best practices ig
	if body is Player && body.is_multiplayer_authority():
		body.take_damage.rpc_id(body.get_multiplayer_authority(),\
			1e10)
