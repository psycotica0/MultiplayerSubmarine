extends StaticBody2D

# This is here to feed my water indicators
signal density_changed(density)

var is_open = true

func _ready():
	# I don't need it to play a bunch of door opening sounds at the start
	var initial = $AudioStreamPlayer2D.volume_db
	$AudioStreamPlayer2D.volume_db = -100
	assert_state()
	yield($AnimationPlayer, "animation_finished")
	$AudioStreamPlayer2D.volume_db = initial

func open():
	$AnimationPlayer.play("Open")
	
	var bottom_room = $BottomRoom.current_room
	var top_room = $TopRoom.current_room
	if bottom_room and top_room:
		bottom_room.link(top_room)
		top_room.link(bottom_room)

func close():
	$AnimationPlayer.play("Close")
	
	var bottom_room = $BottomRoom.current_room
	var top_room = $TopRoom.current_room
	if bottom_room and top_room:
		bottom_room.unlink(top_room)
		top_room.unlink(bottom_room)

func interact(_player):
	is_open = not is_open
	assert_state()

func assert_state():
	if is_open:
		open()
	else:
		close()

func set_state(be_open):
	if (not(is_open) and be_open) or (is_open and not(be_open)):
		is_open = be_open
		assert_state()

func _on_room_changed(_old_room, _new_room):
	if $BottomRoom.current_room and $TopRoom.current_room:
		assert_state()

func _on_room_density_changed(_density):
	emit_signal("density_changed", density())

func density():
	return ($BottomRoom.density() + $TopRoom.density()) / 2.0
