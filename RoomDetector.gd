extends Area2D

signal room_changed(old_room, new_room)
signal room_density_changed(density)

# This is an array because it's possible to be in multiple rooms at once.
# It's also possible to partially enter a room, then leave it again, "remaining"
# in the first room. So I need to know and manage all the rooms
var rooms = []

var current_room

func _on_RoomDetector_area_entered(area):
	rooms.push_front(area)
	room_maybe_changed()

func _on_RoomDetector_area_exited(area):
	rooms.erase(area)
	room_maybe_changed()

# The front method does actually return null if empty,
# but it prints and error to the log first. Dumb.
func maybe_front():
	if rooms.empty():
		return null
	else:
		return rooms.front()

func room_maybe_changed():
	if current_room == maybe_front():
		return
	
	var old_room = current_room
	current_room = maybe_front()
	
	emit_signal("room_changed", old_room, current_room)
	
	if old_room:
		old_room.disconnect("density_changed", self, "density_changed")
	
	if current_room:
		current_room.connect("density_changed", self, "density_changed")
	
	density_changed(density())

func density():
	if current_room:
		return current_room.density()
	else:
		return 0.0

func density_changed(density):
	emit_signal("room_density_changed", density)
