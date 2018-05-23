extends Node

export var sync_properties = []
export var interpolation = true

export var _network_owner = 1

var _sync_node_setted = false    
onready var _tween = _make_tween()
var _last_value_sent = {}

signal net_node_setted(net_node)

var _is_sync_initialized = false

func set_interpolation(value):
	interpolation = value

func init_sync():
	# Init function overridable
	_is_sync_initialized = true
	
func connect_net_node(net_node):
	net_node.connect("network_initialized", self, "init_sync")

func _enter_tree():
	connect("net_node_setted", self, "connect_net_node")
	set_net_node()
		
func set_net_node():
	var net_node
	if(get_tree().get_root().has_node("NetworkingNode")):
		net_node = get_node("/root/NetworkingNode")
		net_node.add_sync_node(self)
		_sync_node_setted = true
		emit_signal("net_node_setted", net_node)
		



func _ready():
	set_process(true)
	
func is_mine():
	return _network_owner == get_tree().get_network_unique_id()
	

func get_network_owner():
	return _network_owner
	
func set_network_owner(owner):
	# print(str(owner)+" own player")
	_network_owner = owner

func _make_tween():
	var tween = Tween.new()
	self.add_child(tween)
	return tween

func _process(delta):
	if not _sync_node_setted:
		set_net_node()
	elif not _is_sync_initialized:
		init_sync()
	elif get_network_owner() != get_tree().get_network_unique_id():
		set_network_master(false)
		

func get_sync_state():
	var state = {}
	if sync_properties != null:
		for prop in sync_properties:
			state = put_in_state(prop, get(prop), state)
	if state.keys().size() != 0:
		return state
	else:
		return null

func put_in_state(key,value,state):
	if( _last_value_sent.has(key) ):
			if( _last_value_sent[key] != value ):
				state[key] = value
				_last_value_sent[key] = value
	else:
		state[key] = value
		_last_value_sent[key] = value
	#print(state)
	return state

func sync_update(tick, state):
	if is_mine():
		return
	_tween.stop_all()
	# print(state)
	for prop in state:
		if interpolation:
			if self.has_method("custom_interpolate_"+prop):
				self.call("custom_interpolate_"+prop, state[prop], tick)
			else:
				_tween.interpolate_property(self, prop, get(prop), state[prop], tick, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		else:
			set(prop, state[prop])
		_tween.start()
	
remote func receive_input(event):
	process_input(event)
	
func process_input(event):
	pass