extends Area2D

@export var speed: int = 500
@export var damage: int


func _process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mech"):
		body.take_damage(damage)
		queue_free()
	if body.is_in_group("small_mech"):
		body.take_damage(damage)
		queue_free()
	if body.is_in_group("pilot"):
		body.take_damage(damage)
		queue_free()
	if body.is_in_group("building"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("building"):
		queue_free()
