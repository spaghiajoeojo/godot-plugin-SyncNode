extends "SyncSpatial.gd"

func init_sync():
	if not is_mine() and get("mode") == RigidBody.MODE_RIGID:
		set("mode", RigidBody.MODE_KINEMATIC)
