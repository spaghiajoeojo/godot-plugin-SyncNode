extends Node

export var server_port = 1337
export var max_clients = 4
export var update_frequency = 15
export(String) var nickname = "player"
export(bool) var auto_spawning = false
export(bool) var dedicated_server = false
export(String) var player_resource
onready var player_scene = load(player_resource)
export(NodePath) var spawn_points

var _network_node

func _ready():
	_load_singleton()

func _load_singleton():
	if( get_tree().get_root().has_node("NetworkingNode") ):
		return
	else:
		var netNode = Node.new()
		netNode.set_name("NetworkingNode")
		var script = preload("res://addons/SyncNode/NetworkingNode.gd")
		netNode.set_script(script)
		netNode.server_port = server_port
		netNode.max_clients = max_clients
		netNode.update_frequency = update_frequency
		netNode.info = nickname
		netNode.lobby = self
		_network_node = netNode
		get_tree().get_root().call_deferred("add_child", netNode)
		
sync func instantiate_player(peer_id):
	var player = player_scene.instance()
	print(player.get_class())
	player.set("transform", Transform(get_node(spawn_points).get("transform").basis, get_node(spawn_points).get("transform").origin))
	player.set_network_owner(peer_id)
	player.set_name(str(peer_id))
	call_deferred("add_child", player)
	print("spawned: "+str(peer_id))
	
func spawn_player(peer_id):
	rpc("instantiate_player", peer_id)