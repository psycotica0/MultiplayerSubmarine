extends RigidBody2D

signal power_changed(left_power, right_power)

const Player = preload("res://Player.tscn")
const Damage = preload("res://Damage.tscn")

export (int, -4, 4) var current_helm = 0
export (int, -2, 4) var current_throttle = 0

export var speed = 7000
export var brake_power = 2000
export var max_thrust_angle = 60
export var drag = 100

var prev_left_pos
var prev_right_pos

var prev_linear_velocity
var prev_angular_velocity

var left_power = 0
var right_power = 0

# Through some testing it seems like level 1 damage is around 400
# Level 3 is around 2000
# The accel is taken as distance_squared so I don't have to take the sqrt
const dmg_level1 = 400 * 400
const dmg_level2 = 1200 * 1200
const dmg_level3 = 2000 * 2000

var damages = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var me = Player.instance()
	me.local = true
	me.submarine = self
	$Players.call_deferred("add_child", me)
	
#	apply_central_impulse(Vector2.UP * speed / 15)
	pass # Replace with function body.

func _integrate_forces(state):
	var hits = {}
		
	for i in range(0, state.get_contact_count()):
		if not state.get_contact_collider_object(i).collision_layer & 1:
			# For these purposes, only care about ship-level collisions.
			# Otherwise players running into the wall inside will be considered
			# to have hit the ship and will do damage
			continue
		
		var local_p = to_local(state.get_contact_collider_position(i))
		var current_v = velocity_at_position(local_p, state.linear_velocity, state.angular_velocity)
		var previous_v = velocity_at_position(local_p, prev_linear_velocity, prev_angular_velocity)
		var accel = ((current_v - previous_v) / state.step).length_squared()
		
		if accel < dmg_level1:
			continue
		
		var damage = 1
		if accel > dmg_level3:
			damage = 3
		elif accel > dmg_level2:
			damage = 2
			
		var grid = (local_p / 16).floor() * 16
		if hits.has(grid):
			hits[grid] = max(damage, hits[grid])
		else:
			hits[grid] = damage
	
	for pos in hits:
		if damages.has(pos):
			if hits[pos] > damages[pos].level:
				damages[pos].level = hits[pos]
			else:
				damages[pos].level += 1
		else:
			var d = Damage.instance()
			damages[pos] = d
			d.connect("tree_exiting", self, "_cleanup_damage", [pos])
			d.level = hits[pos]
			d.position = pos
			$Damage.call_deferred("add_child", d)
	
	prev_angular_velocity = state.angular_velocity
	prev_linear_velocity = state.linear_velocity

func velocity_at_position(local_position, linear_v, angular_v):
	var new_location = local_position.rotated(angular_v)
	new_location += linear_v
	
	return new_location - local_position

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

func _cleanup_damage(pos):
	damages.erase(pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
