extends KinematicBody2D

# Controls if this player is the local player or not
export var local = false

export var speed = 15
export var move_latch = false

func _ready():
	if local:
		$Camera2D.current = true
	pass # Replace with function body.

func _physics_process(_delta):
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
		var _c = move_and_collide(velocity.normalized() * speed)
		# Only set flip_h if it needs to be different.
		# So if I'm going south, I don't change it
		if $Sprite.flip_h and velocity.x > 0:
			$Sprite.flip_h = false
		elif not $Sprite.flip_h and velocity.x < 0:
			$Sprite.flip_h = true
		move_latch = true
	else:
		$AnimationPlayer.play("Stop")

func reset_move_latch():
	move_latch = false
