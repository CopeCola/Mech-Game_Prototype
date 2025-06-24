extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var damage:= 3


func _input(event: InputEvent) -> void:
	pass


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())


func _on_small_mech_sword_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(damage)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "basic_swing":
		queue_free()


func _on_small_mech_sword_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
