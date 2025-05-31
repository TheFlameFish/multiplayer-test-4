class_name Notification extends VBoxContainer

const self_scene = preload("res://ui/notification.tscn")

var title: String
var content: String

var hovered: bool = false

var fadeTween: Tween

@export var titleLabel: Label
@export var contentLabel: Label
@export var closeButton: Button

static func create(title: String, content: String) -> Notification:
	var obj: Notification = self_scene.instantiate()
	obj.title = title
	obj.content = content
	return obj

func _ready() -> void:
	modulate.a = 0
	_fade(1, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	titleLabel.text = title
	contentLabel.text = content


func _on_close_button_pressed() -> void:
	# Could use the fancy fade, but the player probably
	# doesn't wanna wait for that.
	# Also avoids funky tween overlap I think
	queue_free()
	
func _fade(value: float, duration = 2.0) -> void:
	if fadeTween:
		fadeTween.kill()
	fadeTween = get_tree().create_tween()
	fadeTween.tween_property(self, "modulate:a", value, duration)
	fadeTween.play()
	await fadeTween.finished
	fadeTween.kill()

## Fade and then delete.
## Return true if successful, false if interrupted.
func remove(interruptable: bool = true) -> bool:
	_fade(0)
	while modulate.a != 0 && (!hovered || !interruptable):
		await get_tree().create_timer(0.001).timeout
	
	if hovered && interruptable:
		_fade(1, 0)
		return false
	else:
		queue_free()
		return true

func _update_mouse_hover(state: bool):
	hovered = state
	print(state)
