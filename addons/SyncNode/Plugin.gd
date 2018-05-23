tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("SyncNode", "Node", preload("SyncNode.gd"), preload("icon-node.png"))
	add_custom_type("SyncNode2D", "Node2D", preload("SyncNode2D.gd"), preload("icon-node2d.png"))
	add_custom_type("SyncSpatial", "Spatial", preload("SyncSpatial.gd"), preload("icon-spatial.png"))
	add_custom_type("SyncRigidBody", "RigidBody", preload("SyncRigidbody.gd"), preload("icon-rigidbody.png"))
	add_custom_type("SyncKinematicBody", "KinematicBody", preload("SyncSpatial.gd"), preload("icon-kinematic.png"))
	add_custom_type("SyncManager", "Node", preload("SyncManager.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type("SyncNode")
	remove_custom_type("SyncSpatial")
	remove_custom_type("SyncRigidbody")
	remove_custom_type("SyncKinematicbody")
	remove_custom_type("SyncManager")
	remove_custom_type("SyncNode2D")