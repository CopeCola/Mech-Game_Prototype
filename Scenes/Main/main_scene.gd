extends Node2D

@onready var label: Label = $CanvasLayer/Control/Label


func _process(delta: float) -> void:
	label.text = "survivors rescued: " + str(GameManager.score)
