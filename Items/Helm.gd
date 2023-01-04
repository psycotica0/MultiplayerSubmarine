extends StaticBody2D

func interact(player):
	player.take(self)

func taken(player):
	# This is a bit of a hack...
	# Should probably have a better way to talk to the player's ENUM at least
	player.change_state(Player.STATE.DRIVING)
	$Hover.visible = false
	# XXX: I'll have to broadcast to other players that I'm not available
	$CollisionShape2D.disabled = true

func dropped(player):
	$CollisionShape2D.disabled = false
