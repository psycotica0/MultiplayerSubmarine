extends KinematicBody2D

# Controls if this player is the local player or not
export var local = false

export var speed = 15
export var move_latch = false

var submarine

var hovered_item
var held_item

enum STATE { MOVING, DRIVING }

export (STATE) var state

func _ready():
	if local:
		$Camera2D.current = true
	else:
		# Non-local players shouldn't highlight things they're near
		$HandZone/Hand.monitorable = false
		$HandZone/Hand.monitoring = false
	change_state(STATE.MOVING)

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
			$AnimationTree["parameters/playback"].travel("InsideCamera")
		STATE.DRIVING:
			$AnimationTree["parameters/playback"].travel("HelmCamera")
	
func process_moving(_delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		if hovered_item and hovered_item.has_method("interact"):
			hovered_item.interact(self)
	
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
		$AnimationPlayer.play("Run")
		# No delta because of the latch, we only move one frame
		var _c = move_and_collide(velocity.normalized().rotated(global_rotation) * speed, false)
		# Only set flip_h if it needs to be different.
		# So if I'm going south, I don't change it
		if $Sprite.flip_h and velocity.x > 0:
			$Sprite.flip_h = false
			$HandZone.rotation = 0
		elif not $Sprite.flip_h and velocity.x < 0:
			$Sprite.flip_h = true
			$HandZone.rotation = PI
		move_latch = true
	else:
		$AnimationPlayer.play("Stop")

func process_driving(_delta):
	if Input.is_action_just_pressed("ui_up"):
		submarine.increase_throttle(1)
	if Input.is_action_just_pressed("ui_down"):
		submarine.increase_throttle(-1)
	
	if Input.is_action_just_pressed("ui_right"):
		submarine.move_helm(1)
	if Input.is_action_just_pressed("ui_left"):
		submarine.move_helm(-1)
	
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
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
	$AnimationPlayer.playback_speed = lerp(1.0, 0.25, density)
