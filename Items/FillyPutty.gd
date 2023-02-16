extends StaticBody2D

var used_up = false

# I store this so I get dropped I got back to whatever layout I was in before
var original_parent

func _ready():
	if not original_parent:
		original_parent = get_parent()

func interact(player):
	player.take(self)

func use_on(player, item):
	if item:
		if item.has_method("fill"):
			item.fill()
			used_up = true
			player.drop()
		else:
			item.interact(player)
	else:
		# This is when I'm just swinging it around
		# I should _probably_ play some kind of animation here...
		pass

func taken(player):
	$CollisionShape2D.disabled = true
	player.attach(self)
	player.item_layer(Player.PUTTY_LAYER)
	position = Vector2.ZERO

func dropped(player):
	if used_up:
		queue_free()
	else:
		player.detach(self)
		original_parent.add_child(self)
		global_position = player.global_position
		$CollisionShape2D.disabled = false
