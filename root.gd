class_name Game extends Node

@export var multiplayer_ui: Control
@export var oid_label: Label
@export var oid_input: LineEdit
## Container to be hidden until connected to server
@export var connected_controls: Container
@export var server_input: LineEdit

@export var notification_manager: NotificationManager

@onready var level = $Level
@onready var player_spawner = $PlayerSpawner

const PLAYER = preload("res://player/player.tscn")

var players: Array[Player] = []

func _ready() -> void:
	player_spawner.spawn_function = add_player
	
	await MultiplayerManager.on_noray_connected
	oid_label.text = Noray.oid
	
	MultiplayerManager.on_noray_disconnected.connect(_on_noray_disconnected)
	multiplayer.server_disconnected.connect(_on_host_left)

func _process(delta: float) -> void:
	connected_controls.visible = \
		MultiplayerManager.server_connected

func _on_host_pressed() -> void:
	print("Attempting to host on " + Noray.oid)
	MultiplayerManager.host()
	
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
	print("Attempting to join " + oid_input.text)
	MultiplayerManager.join(oid_input.text)
	
	multiplayer_ui.hide()
	
	await get_tree().create_timer(5).timeout
	if !MultiplayerManager.host_connected:
		multiplayer_ui.show()
		multiplayer.multiplayer_peer.close()
		notification_manager.add_notification("Connection error",
			"Failed to connect to host.")
	else:
		notification_manager.add_notification("Yahoo", "yay")

func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)

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


func _on_connect_pressed() -> void:
	var address = server_input.text
	
	MultiplayerManager.setup(address)

	await get_tree().create_timer(2).timeout
	if !MultiplayerManager.server_connected:
		notification_manager.add_notification("Connection Error", \
			"Failed to connect to server.")

func _on_noray_disconnected():
	multiplayer_ui.visible = true
	notification_manager.add_notification("Server disconnected.",
		"Lost connection to Noray server")

func _on_host_left():
	multiplayer_ui.visible = true
	notification_manager.add_notification("Host disconnected.", 
		"Lost connection to lobby host.")
