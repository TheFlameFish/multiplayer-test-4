extends Area2D

var speed = 250
var damage = 25

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if !is_multiplayer_authority():
		return
		
	if body is Player:
		body.take_damage.rpc_id(body.get_multiplayer_authority(),\
			damage)

	kill.rpc()

@rpc("call_local")
func kill():
	queue_free()
