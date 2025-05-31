class_name NotificationManager extends Control

@export var container: Container

func add_notification(title: String, content: String, time: int = 5):
	var alert = Notification.create(title, content)
	container.add_child(alert)
	print("Notif " + title + ": " + content)
	
	# Repeat until the notif is deleted without interruption
	var delete_successful = false
	while !delete_successful:
		await get_tree().create_timer(time).timeout
		if not alert: # If alert deleted itself
			delete_successful = true
		else:
			delete_successful = await alert.remove()
