extends RigidBody2D

signal power_changed(left_power, right_power)

const Player = preload("res://Player.tscn")

export (int, -4, 4) var current_helm = 0
export (int, -2, 4) var current_throttle = 0

export var speed = 7000
export var brake_power = 2000
export var max_thrust_angle = 60
export var drag = 100

var prev_left_pos
var prev_right_pos

var left_power = 0
var right_power = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var me = Player.instance()
	me.local = true
	me.submarine = self
	$Players.call_deferred("add_child", me)
	
#	apply_central_impulse(Vector2.UP * speed / 15)
	pass # Replace with function body.

func _physics_process(delta):
	
	if not prev_left_pos and not prev_right_pos:
		prev_left_pos = $LeftBrake.global_position
		prev_right_pos = $RightBrake.global_position
		return
	
	
	if false:
		var thrust = Vector2.UP * speed * inverse_lerp(0, 4, current_throttle) * delta
		# This version of the steering is thrust vectoring from the back
		# It has a very peculiar feel... but it is kinda fun in its own way...
		# I don't think it's wrong... just weird...
		thrust = thrust.rotated(deg2rad(inverse_lerp(0, 4, -current_helm) * max_thrust_angle))
		apply_impulse($Engine.global_position - global_position, thrust.rotated(global_rotation))
	else:
		# This version is a more familiar style where we mix the power between
		# left and right engines based on helm
		var speed_per_power = speed / 32
		
		var thrust = Vector2.UP.rotated(global_rotation) * delta * speed_per_power
		
		apply_impulse($LeftBrake.global_position - global_position, thrust * left_power)
		apply_impulse($RightBrake.global_position - global_position, thrust * right_power)

	
	
#	thrust = Vector2.UP * speed * delta
	
#	apply_central_impulse(thrust.rotated(global_rotation))
	
#	apply_impulse($RightBrake.global_position - global_position, (Vector2.DOWN * brake_power * delta).rotated(global_rotation))
#	apply_impulse(to_global(Vector2.UP * 1000) - global_position, thrust.rotated(global_rotation))
	var left_pos = $LeftBrake.global_position
	var right_pos = $RightBrake.global_position
	
	var left_v = (left_pos - prev_left_pos) / delta
	var right_v = (right_pos - prev_right_pos) / delta
	
	apply_impulse(left_pos - global_position, -drag * left_v * delta)
	apply_impulse(right_pos - global_position, -drag * right_v * delta)
	
	prev_left_pos = left_pos
	prev_right_pos = right_pos

func increase_throttle(amount):
	current_throttle = clamp(current_throttle + amount, -2, 4)
	compute_power()

func move_helm(amount):
	current_helm = clamp(current_helm + amount, -4, 4)
	compute_power()

func compute_power():
	# Ok, I've got 4 levels of throttle, and each of those has 8 levels of helm
	# This means my throttle produces a maximum of 32 units of power.
	# Then my helm directs those between the two engines.
	# So, full thrust full left is 32 over there
	# But half thrust full left is only 16
	# And full thrust and one off from left is 28 left and 4 right.
	# And 3/4 thrust one off from full left is 21 and 3. Etc
	
	var total_power = current_throttle * 8
	
	# My left engine is fully powered when my throttle is to the right (+4)
	# So I shift it to get 8/8 and multiply by total
	left_power = (total_power * (current_helm + 4)) / 8
	right_power = total_power - left_power
	
	emit_signal("power_changed", left_power, right_power)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
