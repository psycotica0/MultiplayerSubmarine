extends Node2D

const Player = preload("res://Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var me = Player.instance()
	me.local = true
	$Players.call_deferred("add_child", me)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
