# SyncNode
A custom node synchronized over the network

# How to use
1. Create a new node of type "SyncManager"
2. Use a "SyncNode" to synchronize any property of a node (or extend "addons/SyncNode.gd" in scripts)
3. Use SyncSpatial or SyncRigidBody to synchronize position (with interpolation and lag compensation)
