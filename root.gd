class_name Game extends Node

@onready var multiplayer_ui = $UI/Multiplayer
@onready var level = $Level
@onready var player_spawner = $PlayerSpawner

const PLAYER = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()

var players: Array[Player] = []

func _ready() -> void:
	player_spawner.spawn_function = add_player

func _on_host_pressed() -> void:
	peer.create_server(24248)
	multiplayer.multiplayer_peer = peer
	
	player_spawner.spawn(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer connected: " + str(pid))
			player_spawner.spawn(pid)
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

func get_spawnpoints() -> Array:
	var spawnpoints = []
	for child in level.get_children():
		if child.name.contains("SpawnPoint"):
			spawnpoints.append(child)
	
	return spawnpoints

func add_player(pid) -> Player:
	var player = PLAYER.instantiate()
	player.name = str(pid)
	
	var spawnpoints = get_spawnpoints()
	
	var spawn = \
		spawnpoints[players.size() % spawnpoints.size()]
		
	player.global_position = spawn.global_position
	
	players.append(player)
	return player
