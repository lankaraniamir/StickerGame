extends Area2D

@export var speed = 1000

func _physics_process(delta):
	position += (speed * delta) * Vector2(1, 0).rotated(rotation)
	add_to_group("bullet")

func _on_area_entered(area):
	if area.is_in_group("player"):
		#area.hit()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
