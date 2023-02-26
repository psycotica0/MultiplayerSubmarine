extends StaticBody2D

var current_user

func interact(player):
	player.take(self)

func taken(player):
	# This is a bit of a hack...
	# Should probably have a better way to talk to the player's ENUM at least
	player.change_state(Player.STATE.DRIVING)
	$Hover.visible = false
	# XXX: I'll have to broadcast to other players that I'm not available
	$CollisionShape2D.disabled = true
	current_user = player

func dropped(player):
	if player:
		player.change_state(Player.STATE.MOVING)
	$CollisionShape2D.disabled = false
	current_user = null
