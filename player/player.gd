class_name Player extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const MAX_HEALTH = 100.0

const BULLET = preload("res://bullet/bullet.tscn")

@onready var game: Game = get_parent()
@onready var sprite: Sprite2D = $Sprite2D
@onready var gun = $Gun

var health = MAX_HEALTH
var lifetime = 0

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready() -> void:
	if is_multiplayer_authority():
		sprite.modulate = Color.LIGHT_BLUE
	else:
		sprite.modulate = Color.RED

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
		
	lifetime += delta
	
	if lifetime < 0.1:
		return # Funky stuff can happen if we try to do physics before syncing with server
	
	gun.look_at(get_global_mouse_position())
	
	gun.get_node("Sprite").flip_v = \
		get_global_mouse_position().x < global_position.x
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("plat_shoot"):
		shoot.rpc(multiplayer.get_unique_id())

	# Handle jump.
	if Input.is_action_just_pressed("plat_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("plat_left", "plat_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

@rpc("call_local")
func shoot(shooter_pid: int):
	var bullet = BULLET.instantiate()
	bullet.set_multiplayer_authority(shooter_pid)
	bullet.global_transform = gun.get_node("Sprite/Muzzle").global_transform
	get_parent().add_child(bullet)

@rpc("any_peer", "call_local")
func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		health = MAX_HEALTH
		global_position = \
			game.get_spawnpoints().pick_random().global_position
