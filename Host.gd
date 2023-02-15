extends Node2D

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(8374)
	var tree = get_tree()
	tree.network_peer = peer
	DataManager.player_name = "Hosty"
	DataManager.player_colour = Player.PColour.Purple
	DataManager.network_peer_loaded()
	prints("HELLO!")
	tree.change_scene("res://World.tscn")
