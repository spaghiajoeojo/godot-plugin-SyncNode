extends "SyncNode.gd"

export var sync_transform = true

func _ready():
	if sync_transform:
		sync_properties.append("transform")
		
func custom_interpolate_transform(new_value, tick):
	# prediction
	var transform = get("transform")
	var new_transform = new_value
	var vel = (new_transform.origin - transform.origin)
	new_transform.translated(vel)
	# Angular prediction WIP (TODO)
	var ang_vel = (new_transform.basis.get_euler() - get("transform").basis.get_euler())
	var new_basis = Basis(new_transform.basis.get_euler() + ang_vel)
	new_transform.basis =  new_basis
	_tween.interpolate_property(self, "transform/origin", transform.origin, new_transform.origin, tick, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.interpolate_property(self, "transform/rotation_degrees", transform.basis.get_euler(), new_transform.basis.get_euler(), tick, Tween.TRANS_LINEAR, Tween.EASE_OUT)
