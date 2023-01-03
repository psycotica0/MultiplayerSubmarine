extends Node2D

# The room who I represent
export (NodePath) var room

func _ready():
	var r = get_node(room)
	r.connect("density_changed", self, "density_changed")
	density_changed(r.density())
	pass # Replace with function body.

func density_changed(density):
	# I never want it to be fully water
	$Sprite.modulate.a = density * 0.7
