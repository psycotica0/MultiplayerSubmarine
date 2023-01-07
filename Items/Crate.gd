extends StaticBody2D

const FillyPutty = preload("res://Items/FillyPutty.tscn")

func interact(player):
	player.wait()
	yield(player, "waiting_done")
	var p = FillyPutty.instance()
	# If they drop this later, which layer should it be on
	p.original_parent = get_parent()
	player.take(p)
