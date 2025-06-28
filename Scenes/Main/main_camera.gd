extends Camera2D
class_name MainCamera

enum CameraState {ON_MECH, ON_SMALL_MECH, ON_PILOT}

@onready var state = CameraState.ON_MECH
var target_zoom: Vector2 = mech_zoom

@export var mech_zoom := Vector2(1,1)
@export var small_mech_zoom := Vector2(3,3)
@export var pilot_zoom := Vector2(4,4)
@export var zoom_transition_speed: float = 5.0
@export var pos_smoothing_speed: float = 5.0


func _ready() -> void:
	GameManager.connect("camera_state_changed", set_camera_state)
	update_target_zoom()

func _process(delta: float) -> void:
	var target_pos: Vector2
	match state:
		CameraState.ON_MECH:
			target_pos = GameManager.mech_pos
		CameraState.ON_SMALL_MECH:
			target_pos = GameManager.small_mech_pos
		CameraState.ON_PILOT:
			target_pos = GameManager.pilot_pos
	
	if target_pos:
		global_position = global_position.lerp(target_pos, pos_smoothing_speed * delta)

	zoom = zoom.lerp(target_zoom, zoom_transition_speed * delta)


func set_camera_state(new_state: CameraState):
	if state != new_state:
		state = new_state
		update_target_zoom()


func update_target_zoom():
	match state:
		CameraState.ON_MECH:
			target_zoom = mech_zoom
		CameraState.ON_SMALL_MECH:
			target_zoom = small_mech_zoom
		CameraState.ON_PILOT:
			target_zoom = pilot_zoom
