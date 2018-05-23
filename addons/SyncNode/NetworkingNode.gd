extends Node
# SINGLETON

var server_port
var max_clients
sync var clients = {} setget print_value

var lobby

signal player_connected(player_id)
signal network_initialized

var time = 0
var last_time = 0
export var sync_nodes = []
var is_server = false
var is_network_active = false
var info # nickname of the client

func _ready():
	# set_process_input(true)
	get_tree().connect("network_peer_connected", self, "notify_new_peer")
	
func notify_new_peer(id):
	emit_signal("player_connected", id)

func print_value(value):
	clients = value
	print(value)

func create_server():
	set_network_master(true)
	var host = NetworkedMultiplayerENet.new()
	host.create_server(server_port, max_clients)
	get_tree().set_network_peer(host)
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	print("server created")
	is_server = true
	_start_custom_update()
	is_network_active = true
	emit_signal("network_initialized")

func _client_disconnected(id):
	clients.erase(id)
	rset("clients", clients)
	print(info+" id:"+str(id)+" disconnected")
	print(clients)

remote func register_client(id,info):
	clients[id] = info
	rset("clients", clients)
	print(info+" id:"+str(id)+" connected")
	print(clients)

func is_server():
	return is_server
	
func is_network_active():
	return is_network_active

func create_client(server_url, port=null):
	set_network_master(false)
	var client = NetworkedMultiplayerENet.new()
	if port == null:
		client.create_client(server_url, server_port)
	else:
		client.create_client(server_url, port)
	get_tree().set_network_peer(client)
	get_tree().connect("connected_to_server", self, "_connected_ok")
	print("client created")
	is_network_active = true
	_start_custom_update()
	emit_signal("network_initialized")

func _connected_ok():
	var peer_id = get_tree().get_network_unique_id()
	rpc_id(1,"register_client", peer_id, info)
	if lobby.auto_spawning:
		lobby.spawn_player(peer_id)
	print(clients)

func update_remote_state(tick):
	if not is_network_active:
		return
	var states = {}
	for node in sync_nodes:
		if not node.is_mine():
			continue
		var state = node.get_sync_state()
		if state != null:
			states[node.get_path()] = state
	time += 1
	# print(states)
	if states.keys().size() > 0:
		if is_server():
			rpc_unreliable("update_state", time, tick, states)
		else:
			rpc_unreliable_id(1, "update_state", time, tick, states)

remote func update_state(time, tick, state):
	# print(state)
	if last_time >= time:
		return
	last_time = time
	for node in sync_nodes:
		if state.has(node.get_path()):
			# print(has_node(node.get_path()))
			node.sync_update(tick, state[node.get_path()])

func add_sync_node(node):
	sync_nodes.append(node)

var _timer

func _init_timer():
	var timer = Timer.new()
	self.add_child(timer)
	timer.connect("timeout", self, "_custom_update")
	return timer

var update_frequency setget _change_tick

func _change_tick(value):
	update_frequency = value
	_start_custom_update()
	
func _start_custom_update():
	if is_network_active():
		return
	if typeof(_timer) == TYPE_NIL:
		_timer = _init_timer()
	_timer.stop()
	var tick = 1.0/update_frequency
	_timer.set_wait_time(tick)
	_timer.set_one_shot(false)
	_timer.start()
	print("netloop started")

func _custom_update():
	update_remote_state(1.0/update_frequency)
	
var _last_time_input = {}

func _input(event):
	pass
#	if not is_network_active:
#		return
#	if get_tree().get_network_unique_id() != 1:
#		if event.get_class() != "InputEventMouseMotion":
#			rpc_id( 1, "receive_input", event, get_tree().get_network_unique_id())

remote func receive_input(event, peer_id):
#	if _last_time_input.has(peer_id):
#		if _last_time_input[peer_id] > event.ID:
#			return
#	_last_time_input[peer_id] = event.ID
	for node in sync_nodes:
		if node.get_network_owner() == peer_id:
			node.process_input(event)
			
func set_interpolation(value):
	rpc("sync_set_interpolation", value)
		
sync func sync_set_interpolation(value):
	for node in sync_nodes:
		node.set_interpolation(value)

### DEPRECATED (?)
#func event_pack(event):
#	var pack = {}
#	pack["ID"] = event.ID
#	pack["type"] = event.type
#	pack["device"] = event.device
#	if event.type == InputEvent.KEY:
#		pack["scancode"] = event.scancode
#		pack["pressed"] = event.pressed
#		pack["echo"] = event.echo
#	elif event.type == InputEvent.MOUSE_BUTTON:
#		pack["pressed"] = event.pressed
#		pack["pos"] = event.pos
#		pack["button_index"] = event.button_index
#		pack["button_mask"] = event.button_mask
#		pack["doubleclick"] = event.doubleclick
#	return pack
#
#func event_unpack(pack):
#	var event = InputEvent()
#	event.ID = pack["ID"]
#	event.type = pack["type"]
#	event.device = pack["device"]
#	if event.type == InputEvent.KEY:
#		event.scancode = pack["scancode"]
#		event.pressed = pack["pressed"]
#		event.echo = pack["echo"]
#	elif event.type == InputEvent.MOUSE_BUTTON:
#		event.pressed = pack["pressed"]
#		event.pos = pack["pos"]
#		event.button_index = pack["button_index"]
#		event.button_mask = pack["button_mask"]
#		event.doubleclick = pack["doubleclick"]
#	return event