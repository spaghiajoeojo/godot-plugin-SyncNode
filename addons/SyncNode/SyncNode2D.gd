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
	# Angular prediction
	var ang_vel = (new_transform.basis.get_euler() - get("transform").basis.get_euler())
	new_transform.rotated(ang_vel)
	_tween.interpolate_property(self, "transform", transform, new_transform, tick, Tween.TRANS_LINEAR, Tween.EASE_OUT)