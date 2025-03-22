extends Node


@onready var info_panel = $info_panel
@onready var name_label = $info_panel/name_label
@onready var squirrel_avatar = $info_panel/squirrel_avatar





func _ready():
	for sn in $tree_container.get_children():
		print("Test node:", sn.name)
		if sn is SquirrelNode:
			print("→ C'est un SquirrelNode, connexion du signal")
			sn.show_info_requested.connect(_on_squirrel_info_requested)
			
			
func _on_squirrel_info_requested(sn: SquirrelNode):
	print("yup")
	name_label.text = sn.squirrel_name
	squirrel_avatar.texture = sn.squirrel_avatar
	print(sn.avatar)
	info_panel.visible = true
	
	
	
