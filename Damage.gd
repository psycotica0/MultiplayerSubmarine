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
