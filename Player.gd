extends KinematicBody2D

class_name Player

enum PColour {
	Purple,
	Black,
	Blue,
	Brown,
	Green,
	Orange
}

signal waiting_done()

# Controls if this player is the local player or not
export var local = false

export var speed = 15
export var move_latch = false

var submarine

var hovered_item
var held_item

# This is not the node name, but the username of the player who's playing this
var player_name
var colour

var current_room setget ,_get_current_room

const EMPTY_LAYER = 1 << 7 # 128
const VACUUM_LAYER = 1 << 8 # 256
const PUTTY_LAYER = 1 << 9

enum STATE { MOVING, DRIVING, WAITING }

export (STATE) var state

func _ready():
	if local:
		$Camera2D.current = true
	else:
		# Non-local players shouldn't highlight things they're near
		$HandZone/Hand.monitorable = false
		$HandZone/Hand.monitoring = false
	change_state(STATE.MOVING)
	
	for param in ["WalkingMode/Running/blend_amount", "WalkingMode/Facing/blend_position", "WalkingMode/RunSpeed/scale"]:
		$AnimationTree.rset_config("parameters/" + param, MultiplayerAPI.RPC_MODE_REMOTESYNC)

func _physics_process(delta):
	if not local:
		return

	match(state):
		STATE.MOVING:
			process_moving(delta)
		STATE.DRIVING:
			process_driving(delta)

func change_state(new_state):
	if new_state == state:
		return
	
	state = new_state
	match(state):
		STATE.MOVING:
			$AnimationTree["parameters/playback"].travel("WalkingMode")
		STATE.DRIVING:
			$AnimationTree["parameters/playback"].travel("DrivingMode")
		STATE.WAITING:
			$AnimationTree["parameters/playback"].travel("Waiting")

puppet func mimic_position(pos):
	global_position = pos
	pass
	
func process_moving(_delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		if hovered_item and hovered_item.has_method("interact"):
			if held_item and held_item.has_method("use_on"):
				held_item.use_on(self, hovered_item)
			else:
				hovered_item.interact(self)
		else:
			if held_item and held_item.has_method("use_on"):
				held_item.use_on(self, null)
	
	if Input.is_action_just_pressed("drop_item"):
		drop()
	
	if move_latch:
		return

	var velocity = Vector2.ZERO
	
	var action_direction = {
		"ui_up": Vector2.UP,
		"ui_down": Vector2.DOWN,
		"ui_left": Vector2.LEFT,
		"ui_right": Vector2.RIGHT
	}
	for dir in action_direction:
		if Input.is_action_pressed(dir):
			velocity += action_direction[dir]
	
	if velocity != Vector2.ZERO:
		$AnimationTree.rset("parameters/WalkingMode/Running/blend_amount", 1)
		# No delta because of the latch, we only move one frame
		var effective_speed = 1.0
		if Input.is_action_pressed("walk"):
			effective_speed = 0.5
		var _c = move_and_collide(velocity.normalized().rotated(global_rotation) * speed * effective_speed, false)
		rpc_unreliable("mimic_position", global_position)
		if velocity.x > 0:
			$AnimationTree.rset("parameters/WalkingMode/Facing/blend_position", 1)
		elif velocity.x < 0:
			$AnimationTree.rset("parameters/WalkingMode/Facing/blend_position", -1)
		
		move_latch = true
	else:
		$AnimationTree.rset("parameters/WalkingMode/Running/blend_amount", 0)

func process_driving(_delta):
	if Input.is_action_just_pressed("ui_up"):
		submarine.increase_throttle(1)
	if Input.is_action_just_pressed("ui_down"):
		submarine.increase_throttle(-1)
	
	if Input.is_action_just_pressed("ui_right"):
		submarine.move_helm(1)
	if Input.is_action_just_pressed("ui_left"):
		submarine.move_helm(-1)
	
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("drop_item"):
		drop()
		change_state(STATE.MOVING)

func reset_move_latch():
	move_latch = false

func do_hover(item):
	var hover = item.get_node("Hover")
	if hover:
		hover.visible = true
		return true
	else:
		return false

func do_nohover(item):
	var hover = item.get_node("Hover")
	if hover:
		hover.visible = false

func take(item):
	drop()
	held_item = item
	if item.has_method("taken"):
		item.taken(self)

func drop():
	if held_item:
		if held_item.has_method("dropped"):
			held_item.dropped(self)
		held_item = null
		item_layer(EMPTY_LAYER)

func attach(item):
	if item.get_parent():
		item.get_parent().remove_child(item)
	$HandZone/Attach.add_child(item)

func detach(item):
	$HandZone/Attach.remove_child(item)

func item_layer(mask):
	$HandZone/Hand.collision_mask = mask

func setColor(pcolor):
	match pcolor:
		PColour.Purple:
			$Sprite.texture = preload("res://Assets/Players/purple.png")
		PColour.Blue:
			$Sprite.texture = preload("res://Assets/Players/blue.png")
		PColour.Black:
			$Sprite.texture = preload("res://Assets/Players/black.png")
		PColour.Brown:
			$Sprite.texture = preload("res://Assets/Players/brown.png")
		PColour.Green:
			$Sprite.texture = preload("res://Assets/Players/green.png")
		PColour.Orange:
			$Sprite.texture = preload("res://Assets/Players/orange.png")
	colour = pcolor

func _on_Hand_body_entered(body : Node2D):
	if do_hover(body):
		if hovered_item:
			do_nohover(hovered_item)
		hovered_item = body

func _on_Hand_body_exited(body):
	if body == hovered_item:
		do_nohover(body)
		hovered_item = null
	# TODO: Look at other items in my area to see if I should hover any of them
	# XXX: Also, I should probably make sure that when someone else picks the
	#      item up it fires this here, so I can unhover it, and look for another
	#      thing to hover

func _on_RoomDetector_room_density_changed(density):
	$AnimationTree.rset("parameters/WalkingMode/RunSpeed/scale", lerp(1.0, 0.25, density))

func _get_current_room():
	return $RoomDetector.current_room

func wait():
	change_state(STATE.WAITING)
	$WaitTimer.start()

func _on_WaitTimer_timeout():
	change_state(STATE.MOVING)
	emit_signal("waiting_done")

# This is called by the DataManager
func snapshot():
	var player_state = {
		"name": player_name,
		"colour": colour,
		"state": 0,
		"pos": position,
		"network_owner": get_network_master()
	}
	# TODO: Held Item
	return player_state
