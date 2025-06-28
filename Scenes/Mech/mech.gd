extends CharacterBody2D
class_name Mech

var testing_git
@onready var animation_player_lights: AnimationPlayer = $AnimationPlayerLights


@onready var minor_mech_sprite: Sprite2D = $MinorMechSprite
@onready var pilot_scene = preload("res://Scenes/Pilot/Pilot.tscn")
@onready var small_mech_scene = preload("res://Scenes/Small_Mech/small_mech.tscn")
@onready var pilot_exit_pos: Marker2D = $PilotExitPos
@onready var small_mech_exit_pos: Marker2D = $SmallMechExitPos
@onready var mech_gun = get_tree().get_first_node_in_group("mech_gun")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var health_bar: TextureProgressBar = $TextureProgressBar

@export var max_speed: float = 20000
var speed: float 
@export var max_health: float = 20

var current_health: float

var pilot: CharacterBody2D
var pilot_is_ejected: bool = false

var small_mech: CharacterBody2D

var dashing: bool = false
var can_dash: bool = true


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("eject_small_mech"):
		if GameManager.in_mech and small_mech == null:
			eject_small_mech()
	if Input.is_action_just_pressed("eject_pilot"):
		if GameManager.in_mech and pilot == null:
			eject_pilot()


	if event.is_action_pressed("dash") and not dashing and can_dash:
		dash()


func _ready() -> void:
	GameManager.mech = self
	current_health = max_health
	speed = max_speed
	health_bar.max_value = max_health
	health_bar.value = max_health


func _process(delta: float) -> void:
	#print(Input.get_vector("move_left","move_right","move_down", "move_up"))
	if GameManager.in_mech and not GameManager.in_small_mech:
		handle_movement(delta)
		GameManager.mech_pos = global_position


		#var mouse_pos = get_global_mouse_position()
		#var target_angle = (mouse_pos - global_position).angle()
		#var angle_diff = wrapf(target_angle - global_rotation, -PI, PI)
	#
		#global_rotation += sign(angle_diff) * min(abs(angle_diff), .5 * delta)

		var mouse_pos = get_global_mouse_position()
		global_rotation = lerp_angle(rotation, mech_gun.global_rotation, 0.005)

func get_move_vector():
	var x_vec = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_vec = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_vec,y_vec).normalized()


func handle_movement(delta_time):
	var direction = get_move_vector()
	velocity = direction * speed * delta_time
	move_and_slide()


func dash():
	if velocity != Vector2.ZERO and GameManager.in_mech:
			dashing = true
			speed *= 3
			await get_tree().create_timer(.2).timeout
			set_disabled_status()
			dashing = false
			can_dash = false
			await get_tree().create_timer(1.5).timeout
			can_dash = true


func eject_pilot():
	var pilot_instance = pilot_scene.instantiate()
	pilot_instance.connect("entered_mech", pilot_in_mech)
	pilot_instance.connect("repaired_mech", set_disabled_status)
	pilot = pilot_instance
	pilot_instance.global_position = pilot_exit_pos.global_position
	#pilot_instance.global_position = GameManager.mech_pos + (get_move_vector() *3)
	get_parent().add_child(pilot_instance)
	GameManager.in_mech = false
	GameManager.pilot_health = GameManager.max_pilot_health
	GameManager.emit_signal("camera_state_changed", MainCamera.CameraState.ON_PILOT)
	
	
	print("pilot in mech: " + str(GameManager.in_mech))
	print("pilot in small mech: " + str(GameManager.in_small_mech))


func eject_small_mech():
	minor_mech_sprite.visible = false
	var small_mech_instance = small_mech_scene.instantiate()
	small_mech_instance.connect("entered_mech", pilot_in_mech)
	small_mech = small_mech_instance
	small_mech_instance.global_position = small_mech_exit_pos.global_position
	get_parent().add_child(small_mech_instance)
	GameManager.in_mech = false
	GameManager.in_small_mech = true
	GameManager.emit_signal("camera_state_changed", MainCamera.CameraState.ON_SMALL_MECH)
	print("pilot in small mech: " + str(GameManager.in_small_mech))

#pilot_instance.connect("was_ejected", pilot_was_ejected)
#func pilot_was_ejected():
	#pass
	#pilot_is_ejected = true


func pilot_in_mech():
	if GameManager.in_mech:
		print("pilot in mech: " + str(GameManager.in_mech))


func pilot_in_small_mech():
	if GameManager.in_small_mech:
		print("pilot in small mech: " + str(GameManager.in_small_mech))
		GameManager.in_mech = false
		GameManager.in_small_mech = true


func take_damage(amount:int):
	if current_health > 0:
		animation_player.play("take_damage")
		await animation_player.animation_finished
		current_health -= amount
		health_bar.value -= amount
		set_disabled_status()
		death()
	else:
		current_health = 0
		speed = 0

func set_disabled_status():
	if current_health <= max_health/3:
		speed = max_speed/3
	elif current_health <= max_health/2:
		speed = max_speed/2
	elif current_health <= max_health/1.5:
		speed = max_speed/1.5
	elif current_health > max_health/1.5:
		speed = max_speed


func death():
	if current_health == 0:
		speed = 0
		print("died")
