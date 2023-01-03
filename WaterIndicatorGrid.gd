extends Node2D

tool

export (Vector2) var size setget _set_size

const TILE_SIZE = 16
const WaterIndicator = preload("res://WaterIndicator.tscn")

func _set_size(new_size):
	size = new_size
	
	for child in get_children():
		child.queue_free()
	
	for x in range(0, size.x):
		for y in range(0, size.y):
			var tile = WaterIndicator.instance()
			tile.position.x = x * TILE_SIZE
			tile.position.y = y * TILE_SIZE
			add_child(tile)
