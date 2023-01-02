extends KinematicBody2D

# Controls if this player is the local player or not
export var local = false

export var speed = 15
export var move_latch = false

var submarine

enum STATE { MOVING, DRIVING }

export (STATE) var state

func _ready():
	if local:
		$Camera2D.current = true
	change_state(STATE.MOVING)

func _physics_process(delta):
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
		var _c = move_and_collide(velocity.normalized() * speed, false)
		# Only set flip_h if it needs to be different.
		# So if I'm going south, I don't change it
		if $Sprite.flip_h and velocity.x > 0:
			$Sprite.flip_h = false
		elif not $Sprite.flip_h and velocity.x < 0:
			$Sprite.flip_h = true
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

func reset_move_latch():
	move_latch = false
