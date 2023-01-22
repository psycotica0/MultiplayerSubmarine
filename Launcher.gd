extends Node2D

func _ready():
	if OS.has_feature("debug"):
		var _r = get_tree().change_scene("res://Host.tscn")
	else:
		# This should be the character picker screen later
		var _r = get_tree().change_scene("res://World.tscn")
