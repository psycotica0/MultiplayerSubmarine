extends StaticBody2D

# I store this so I get dropped I got back to whatever layout I was in before
var original_parent

func _ready():
	original_parent = get_parent()

func interact(player):
	player.take(self)

func taken(player):
	player.attach(self)
	$CollisionShape2D.disabled = true

func dropped(player):
	pass
