extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact(player):
	player.take(self)

func taken(player):
	# This is a bit of a hack...
	# Should probably have a better way to talk to the player's ENUM at least
	player.change_state(1)
	$Hover.visible = false
	# XXX: I'll have to broadcast to other players that I'm not available
	$CollisionShape2D.disabled = true

func dropped(player):
	$CollisionShape2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
