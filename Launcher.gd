extends Node2D

func _ready():
	randomize()

	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]

	if arguments.has("host"):
		# XXX For now the client host is hard-coded
		var _r = get_tree().change_scene("res://Client.tscn")
	elif OS.has_feature("debug"):
		var _r = get_tree().change_scene("res://Host.tscn")
	else:
		# This should be the character picker screen later
		var _r = get_tree().change_scene("res://World.tscn")
