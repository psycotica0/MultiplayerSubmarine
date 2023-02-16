extends Node

const VERSION = "0.0.1"

var player_name : String
var player_colour

# This requires the methods add_player, mourn_player, remove_player, find_player, get_players, clear_players
var player_manager

# This requires the methods add_item, add_item_for_player, item_layer, get_items, clear_items
var item_manager

# GameState is expected to be a dictionary with the following keys:
#   version: A string so we can detect mismatches
#   players: An array containing dicts that look like:
#     name: Player Name string
#     colour: Int that corresponds to colour enum
#     network_owner: Int that corresponds to who owns the player
#     state: 0 for active, 1 for mourning
#     pos: Vector2 for position
#     held_item: Present if the user is holding something, looks like
#       type: The filename of the thing they're holding
#       name: The name of this item
#   items:
#     name: Unique name
#     type: Filename to class
#     pos: Position of the item in the world

func is_host():
	return get_tree().is_network_server()

func network_peer_loaded():
	if is_host():
		# XXX DISCONNECTED TOO
		var _x = get_tree().connect("network_peer_connected", self, "_network_peer_connected")

func snapshot():
	var state = {
		"version": VERSION,
		"players": [],
		"items": []
	}
	
	for player in player_manager.get_players():
		state["players"].append(player.snapshot())
	
	for item in item_manager.get_items():
		state["items"].append({
			"name": item.name,
			"type": item.filename,
			"pos": item.position
		})
	
	return state

remote func load_snapshot(state):
	prints("Loaded", state)
	if state["version"] != VERSION:
		prints("OH SHIT, BAD VERSION! Should be", VERSION, "but it's", state["version"])
		return
	
	player_manager.clear_players()
	for player in state["players"]:
		player_manager.add_player(player["name"], player["colour"], player["network_owner"], player["pos"])
		if player.has("held_item"):
			add_item_to_player(player["held_item"]["name"], player["held_item"]["type"], player["name"])
	
	item_manager.clear_items()
	for item in state["items"]:
		item_manager.add_item(item["name"], item["type"], item["pos"])
	
	rpc("player_ready", player_name, player_colour, Vector2(0,0))

func set_player_manager(m):
	player_manager = m
	if is_host():
		player_manager.add_player(player_name, player_colour, get_tree().get_network_unique_id(), Vector2(0,0))

func set_item_manager(m):
	item_manager = m

func _network_peer_connected(peer):
	var s = snapshot()
	prints("Snapshot", s)
	
	rpc_id(peer, "load_snapshot", s)

remotesync func player_ready(name, colour, position):
	player_manager.add_player(name, colour, get_tree().get_rpc_sender_id(), position)

func new_item_to_player(type, player):
	if player.player_name == player_name:
		# This is used to make sure all players have the same names for all the items
		# So only the local player computes the names, and then they tell the others
		var item_name = "item" + String(randi())
		rpc("add_item_to_player", item_name, type, player_name)

remotesync func add_item_to_player(name, type, holding_player_name):
	var p = load(type).instance()
	p.name = name
	var player = player_manager.find_player(holding_player_name)
	# If they drop this later, which layer should it be on
	p.original_parent = item_manager.item_layer()
	player.take(p)
