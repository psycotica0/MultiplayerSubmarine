extends StaticBody2D

# I store this so I get dropped I got back to whatever layout I was in before
var original_parent

func _ready():
	original_parent = get_parent()

func interact(player):
	player.take(self)

func taken(player):
	player.attach(self)
	position = Vector2(0,0)
	player.item_layer(Player.VACUUM_LAYER)
	$CollisionShape2D.disabled = true

func dropped(player):
	player.detach(self)
	original_parent.add_child(self)
	global_position = player.global_position
	$CollisionShape2D.disabled = false
