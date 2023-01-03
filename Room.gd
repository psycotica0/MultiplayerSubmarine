extends Area2D

# This is a number between 0 and 1, where 1 is "full"
signal density_changed(density)
var last_signalled_density

export (Array, NodePath) var connections
export var size = 0
export var current_volume = 0.0

const FLOW_RATE = 160
# This sets at which difference in density we reach max flow rate
const MAX_GRADIENT = 0.5
var max_volume

func _enter_tree():
	max_volume = size * 100.0

func density():
	return stepify(current_volume / max_volume, 0.01)

func _process(delta):
	for c in connections:
		var other = get_node(c)
		
		var gradient = clamp(density() - other.density(), 0.0, MAX_GRADIENT)
		if gradient <= 0:
			continue
		
		var rate = FLOW_RATE * gradient / MAX_GRADIENT
		current_volume -= other.receive_water(rate * delta)
	density_maybe_changed()

func receive_water(amount):
	var new_volume = clamp(current_volume + amount, 0.0, max_volume)
	var amount_taken = new_volume - current_volume
	current_volume = new_volume
	density_maybe_changed()
	return amount_taken

func density_maybe_changed():
	if last_signalled_density == density():
		return
	
	last_signalled_density = density()
	emit_signal("density_changed", density())
