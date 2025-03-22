extends Node


@onready var info_panel = $info_panel





func _ready():
	for sn in $tree_container.get_children():
		print("Test node:", sn.name)
		if sn is SquirrelNode:
			print("→ C'est un SquirrelNode, connexion du signal")
			sn.show_info_requested.connect(_on_squirrel_info_requested)
			
			
func _on_squirrel_info_requested(sn: SquirrelNode):
	print("yup")
	info_panel.visible = true
	
	
	
