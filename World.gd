extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Submarine_power_changed(left_power, right_power):
	# Negative because this one fills from the right
	$"HUD/DrivingLayer/Control/Left Engine".value = 32 - left_power
	$"HUD/DrivingLayer/Control/Right Engine".value = right_power
