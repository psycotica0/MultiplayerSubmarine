extends Node2D

const MAX_FLOW_RATE = 160

export (int, 0, 3) var level = 1 setget _set_level

func _ready():
	_set_level(level)

func _process(delta):
	var r = $RoomDetector.current_room
	if r:
		# It tells me how much it actually took, but I don't really care here
		var _v = r.receive_water(inverse_lerp(0, 3, level) * MAX_FLOW_RATE * delta)

# If somehow we fall through some case and the player is able to interact with
# us without using the filly putty, just assume we should go away
func interact(_player):
	fill()

# This is called by the filly putty when it's used on this item
func fill():
	queue_free()

func _set_level(new_level):
	level = new_level
	match level:
		1:
			$AnimationPlayer.play("Level1")
		2:
			$AnimationPlayer.play("Level2")
		3:
			$AnimationPlayer.play("Level3")
		_:
			queue_free()
