extends Area2D

@export var sprite: Sprite2D

@export var resource_data: Collectable :
	set(value):
		resource_data = value
		if sprite and resource_data:
			sprite.scale = Vector2(.05,.05)
			sprite.texture = resource_data.texture
			sprite.modulate = resource_data.color


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("pilot"):
		if body.has_method("collect"):
			body.collect(resource_data)
		queue_free()
