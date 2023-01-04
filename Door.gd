extends StaticBody2D

# This is here to feed my water indicators
signal density_changed(density)

var is_open = true

func _ready():
	assert_state()

func open():
	$Closed.visible = false
	$Open.visible = true
	$Blocker/CollisionShape2D.disabled = true
	
	var bottom_room = $BottomRoom.current_room
	var top_room = $TopRoom.current_room
	if bottom_room and top_room:
		bottom_room.link(top_room)
		top_room.link(bottom_room)

func close():
	$Closed.visible = true
	$Open.visible = false
	$Blocker/CollisionShape2D.disabled = false
	
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

func _on_room_changed(_old_room, _new_room):
	if $BottomRoom.current_room and $TopRoom.current_room:
		# It works if I don't do this, but it does put something in the error log
		call_deferred("assert_state")

func _on_room_density_changed(_density):
	emit_signal("density_changed", $BottomRoom.density() + $TopRoom.density() / 2.0)
