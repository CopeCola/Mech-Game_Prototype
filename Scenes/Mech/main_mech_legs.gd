extends Node2D


func _process(delta: float) -> void:
	global_position = GameManager.mech_pos
	
	var mouse_pos = get_global_mouse_position()
	global_rotation = lerp_angle(rotation, GameManager.mech.rotation, 0.005)
