extends StaticBody2D

const SUCK_RATE = 80

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

func use_on(player, item):
	if item:
		# We don't do anything with items, so this is a door or something
		# Ignore the vacuum and just use the other item
		item.interact(player)
	else:
		var room = player.current_room
		if not room or room.density() == 0.00:
			$AnimationPlayer.play("NoSuck")
		else:
			$AnimationPlayer.play("Suck")
			var _a = room.receive_water(-SUCK_RATE)
