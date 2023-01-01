extends RigidBody2D

const Player = preload("res://Player.tscn")

export (int, -4, 4) var current_helm = 0
export (int, -2, 4) var current_throttle = 0

export var speed = 7000
export var brake_power = 2000
export var max_thrust_angle = 60
export var drag = 100

var prev_left_pos
var prev_right_pos

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
	
	var thrust = Vector2.UP * speed * inverse_lerp(0, 4, current_throttle) * delta
	
	if false:
		# This version of the steering is thrust vectoring from the back
		# It has a very peculiar feel... but it is kinda fun in its own way...
		# I don't think it's wrong... just weird...
		thrust = thrust.rotated(deg2rad(inverse_lerp(0, 4, -current_helm) * max_thrust_angle))
		apply_impulse($Engine.global_position - global_position, thrust.rotated(global_rotation))
	else:
		# This version is a more familiar style where we mix the power between
		# left and right engines based on helm
		var left_engine_power = inverse_lerp(-4, 4, current_helm)
		
		apply_impulse($LeftBrake.global_position - global_position, thrust.rotated(global_rotation) * left_engine_power)
		apply_impulse($RightBrake.global_position - global_position, thrust.rotated(global_rotation) * (1 - left_engine_power))

	
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
