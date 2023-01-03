extends StaticBody2D

var open = true

func _ready():
	open()

func open():
	$Closed.visible = false
	$Open.visible = true
	$Blocker/CollisionShape2D.disabled = true

func close():
	$Closed.visible = true
	$Open.visible = false
	$Blocker/CollisionShape2D.disabled = false

func interact(_player):
	if open:
		open = false
		close()
	else:
		open = true
		open()
