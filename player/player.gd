extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

@onready var sprite: Sprite2D = $Sprite2D

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
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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
