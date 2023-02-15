extends Node

const VERSION = "0.0.1"

var player_name : String
var player_colour

# This requires the methods add_player, sleep_player, remove_player
var player_manager

# GameState is expected to be a dictionary with the following keys:
#   version: A string so we can detect mismatches
#   players: An array containing dicts that look like:
#     name: Player Name string
#     colour: Int that corresponds to colour enum
#     network_owner: Int that corresponds to who owns the player
#     state: 0 for active, 1 for mourning
#     pos: Vector2 for position
#     held_item: TODO

func is_host():
	return get_tree().is_network_server()

func network_peer_loaded():
	if is_host():
		# XXX DISCONNECTED TOO
		var _x = get_tree().connect("network_peer_connected", self, "_network_peer_connected")

func snapshot():
	var state = {
		"version": VERSION,
		"players": []
	}
	
	for player in get_tree().get_nodes_in_group("players"):
		state["players"].append(player.snapshot())
	
	return state

remote func load_snapshot(state):
	prints("Loaded", state)
	if state["version"] != VERSION:
		prints("OH SHIT, BAD VERSION! Should be", VERSION, "but it's", state["version"])
		return
	
	for player in state["players"]:
		player_manager.add_player(player["name"], player["colour"], player["network_owner"], player["pos"])
	
	rpc("player_ready", player_name, player_colour, Vector2(0,0))

func set_player_manager(m):
	player_manager = m
	if is_host():
		player_manager.add_player(player_name, player_colour, get_tree().get_network_unique_id(), Vector2(0,0))

func _network_peer_connected(peer):
	var s = snapshot()
	prints("Snapshot", s)
	
	rpc_id(peer, "load_snapshot", s)

remotesync func player_ready(name, colour, position):
	player_manager.add_player(name, colour, get_tree().get_rpc_sender_id(), position)
