extends Node2D

export var host = "localhost"

func _ready():
	get_tree().connect("connected_to_server", self, "_on_connected")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, 8374)
	var tree = get_tree()
	tree.network_peer = peer
	DataManager.player_name = "Clint"
	DataManager.player_colour = Player.PColour.Blue
	DataManager.network_peer_loaded()
	prints("HELLO CLIENT!")

func _on_connected():
	get_tree().change_scene("res://World.tscn")

func _on_connection_failed():
	prints("Shit, no connection")
