class_name NorayHandler extends Node

signal on_noray_connected
signal on_noray_disconnected

var noray_address = ""
const NORAY_PORT = 8890

var server_connected = false

var hosting = false
var external_oid = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Noray.on_connect_to_host.connect(_on_noray_connected)
	Noray.on_disconnect_from_host.connect(_on_noray_disconnected)
	Noray.on_connect_nat.connect(_handle_nat_connection)
	Noray.on_connect_relay.connect(_handle_relay_connection)
	
func setup(address) -> void:
	print("Connecting to server "+ address)
	if server_connected:
		print("Currently connected. Disconnecting first...")
		Noray.disconnect_from_host()
		await get_tree().create_timer(0.01).timeout
		print("Disconnected.")
	
	noray_address = address
	
	print("Connecting to server now.")
	Noray.connect_to_host(noray_address, NORAY_PORT)

func _on_noray_connected():
	print("Connected to Noray")
	
	Noray.register_host()
	await Noray.on_pid
	await Noray.register_remote()
	print("Registered Noray remote.")
	
	on_noray_connected.emit()
	server_connected = true

func _on_noray_disconnected():
	print("Noray server disconnected.")
	
	on_noray_disconnected.emit()
	server_connected = false

func host():
	print("Hosting.")
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Noray.local_port)
	multiplayer.multiplayer_peer = peer
	
	hosting = true

func join(oid: String):
	print("Joining")
	Noray.connect_nat(oid)
	external_oid = oid

func _handle_nat_connection(address, port):
	var err = await connect_to_server(address, port)
	
	if err != OK && !hosting:
		print("NAT failed (heck you, router!). Using relay")
		Noray.connect_relay(external_oid)
		err = OK
	else:
		print("NAT connection OK.")
	
	return err

func _handle_relay_connection(address, port):
	return await connect_to_server(address, port)

func connect_to_server(address, port):
	var err = OK
	
	if !hosting:
		var udp = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_dest_address(address, port)
		
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()
		
		if err != OK:
			if err != ERR_BUSY:
				print("Handshake failed.")
				print(error_string(err))
				return err
		else:
			print("Handshake succeeded.")
			
		var peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
		
		if err != OK:
			return err
			
		multiplayer.multiplayer_peer = peer
	else: # hosting
		err = await PacketHandshake.over_enet(\
			multiplayer.multiplayer_peer.host, address, port)
		
	return err
