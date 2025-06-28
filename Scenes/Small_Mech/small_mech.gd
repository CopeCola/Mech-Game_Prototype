extends CharacterBody2D
class_name SmallMech

signal entered_mech

@export var rotation_speed: float = 5.0 # radians per second
@export var max_angle_offset: float = 0.2 # radians threshold to prevent jitter

var _target_angle: float

@onready var small_mech_sword = preload("res://Scenes/Weapons/small_mech_sword.tscn")
@onready var pilot_scene = preload("res://Scenes/Pilot/Pilot.tscn")
@onready var pilot_exit_pos: Marker2D = $PilotExitPos
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $TextureProgressBar

@export var small_mech_max_speed: float = 25000
var small_mech_speed: float 
@export var small_mech_max_health:float = 20


var pilot: CharacterBody2D
var pilot_is_ejected: bool = false

var dashing: bool = false
var can_dash: bool = true

var can_interact_with_mech: bool = false



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("eject_pilot"):
		if GameManager.in_small_mech == true and pilot == null:
			eject_pilot()
	if Input.is_action_just_pressed("enter_mech"):
		if not GameManager.in_mech and can_interact_with_mech:
			GameManager.in_mech = true
			GameManager.in_small_mech = false
			GameManager.mech.minor_mech_sprite.visible = true
			GameManager.emit_signal("camera_state_changed", MainCamera.CameraState.ON_MECH)

			emit_signal("entered_mech")
			call_deferred("queue_free")
	if Input.is_action_just_pressed("shoot"):
		instantiate_sword(small_mech_sword)

	if Input.is_action_just_pressed("dash") and not dashing and can_dash:
		dash()


func _ready() -> void:
	GameManager.small_mech = self
	GameManager.small_mech_health = GameManager.max_small_mech_health
	small_mech_speed = small_mech_max_speed
	health_bar.max_value = small_mech_max_health
	health_bar.value = small_mech_max_health


func _process(delta: float) -> void:
	if GameManager.in_small_mech and not GameManager.in_mech:
		handle_movement(delta)
		GameManager.small_mech_pos = global_position
			# Get target direction to mouse
		var mouse_pos = get_global_mouse_position()
		_target_angle = (mouse_pos - global_position).angle()
	
	# Calculate needed rotation
		var angle_diff = wrapf(_target_angle - rotation, -PI, PI)
	
	# Apply rotation if difference is large enough
		if abs(angle_diff) > max_angle_offset:
			rotation += sign(angle_diff) * min(abs(angle_diff), rotation_speed * delta)

func get_move_vector():
	var x_vec = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_vec = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_vec,y_vec).normalized()


func handle_movement(delta_time):
	var direction = get_move_vector()
	velocity = direction * small_mech_speed * delta_time
	move_and_slide()


func instantiate_sword(sword_scene: PackedScene):
	if get_tree().get_first_node_in_group("sword") == null:
		var sword_instance = sword_scene.instantiate()
		self.add_child(sword_instance)
		sword_instance.global_position = global_position


func dash():
	if get_move_vector() != Vector2.ZERO:
			dashing = true
			small_mech_speed *= 3
			await get_tree().create_timer(.4).timeout
			set_disabled_status()
			dashing = false
			can_dash = false
			await get_tree().create_timer(1).timeout
			can_dash = true


func eject_pilot():
	var pilot_instance = pilot_scene.instantiate()
	pilot_instance.connect("entered_small_mech", pilot_in_small_mech)
	pilot_instance.connect("repaired_mech", set_disabled_status)
	pilot = pilot_instance
	pilot_instance.global_position = pilot_exit_pos.global_position
	get_parent().add_child(pilot_instance)
	GameManager.in_small_mech = false
	GameManager.pilot_health = GameManager.max_pilot_health
	GameManager.emit_signal("camera_state_changed", MainCamera.CameraState.ON_PILOT)
	
	print("pilot in mech: " + str(GameManager.in_mech))
	print("pilot in small mech: " + str(GameManager.in_small_mech))

#pilot_instance.connect("was_ejected", pilot_was_ejected)
#func pilot_was_ejected():
	#pass
	#pilot_is_ejected = true


func pilot_in_small_mech():
	if GameManager.in_small_mech:
		print("pilot in small mech: " + str(GameManager.in_small_mech))
		GameManager.in_mech = false
		GameManager.in_small_mech = true


func toggle_enemy_targeting():
	pass

func take_damage(amount:int):
	if GameManager.small_mech_health > 0:
		animation_player.play("take_damage")
		await animation_player.animation_finished
		GameManager.small_mech_health -= amount
		health_bar.value -= amount
		set_disabled_status()
		death()
	else:
		GameManager.small_mech_health = 0
		small_mech_speed = 0


func set_disabled_status():
	if GameManager.small_mech_health <= GameManager.max_small_mech_health/3:
		small_mech_speed = small_mech_max_speed/3
	elif GameManager.small_mech_health <= GameManager.max_small_mech_health/2:
		small_mech_speed = small_mech_max_speed/2
	elif GameManager.small_mech_health <= GameManager.max_small_mech_health/1.5:
		small_mech_speed = small_mech_max_speed/1.5
	elif GameManager.small_mech_health > GameManager.max_small_mech_health/1.5:
		small_mech_speed = small_mech_max_speed


func death():
	if GameManager.small_mech_health == 0:
		small_mech_speed = 0
		print("died")


func _on_interact_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mech"):
		can_interact_with_mech = true


func _on_interact_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("mech"):
		can_interact_with_mech = false
	


func _on_small_mech_sword_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(6)
