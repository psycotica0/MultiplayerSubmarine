extends Node2D

func _ready():
	var r = get_parent()
	while r:
		if r.has_signal("density_changed"):
			r.connect("density_changed", self, "density_changed")
			density_changed(r.density())
			break
		r = r.get_parent()

func density_changed(density):
	# I never want it to be fully water
	$Sprite.modulate.a = density * 0.7
