extends StaticBody2D

const FillyPutty = preload("res://Items/FillyPutty.tscn")

func interact(player):
	player.wait()
	yield(player, "waiting_done")
	
	DataManager.new_item_to_player("res://Items/FillyPutty.tscn", player)
