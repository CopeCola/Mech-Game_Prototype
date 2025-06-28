extends Area2D

@export var speed: int = 900


@export var damage: int


func _process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
	if body.is_in_group("building"):
		queue_free()
	if body.is_in_group("mech"):
		return



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.get_parent().take_damage(damage)
	if area.is_in_group("building"):
		queue_free()
