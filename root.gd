extends Node

@onready var multiplayer_ui = $UI/Multiplayer

const PLAYER = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()

func _on_host_pressed() -> void:
	peer.create_server(24248)
	multiplayer.multiplayer_peer = peer
	
	add_player(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer connected: " + str(pid))
			add_player(pid)
	)
	
	multiplayer.peer_disconnected.connect(
		func(pid):
			var player = get_node(str(pid))
			if player:
				player.queue_free()
	)
	
	multiplayer_ui.hide()

func _on_join_pressed() -> void:
	peer.create_client("localhost", 24248)
	multiplayer.multiplayer_peer = peer
	
	multiplayer_ui.hide()

func add_player(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	add_child(player)
