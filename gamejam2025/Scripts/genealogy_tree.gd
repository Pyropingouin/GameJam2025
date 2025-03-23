extends Node


@onready var info_panel = $info_panel
@onready var name_label = $info_panel/name_label
@onready var squirrel_avatar = $info_panel/squirrel_avatar
@onready var description = $info_panel/description
@onready var button_combat = $info_panel/button_combat
@onready var button_cancel = $info_panel/button_cancel
@onready var genealogy_tree = $"."

var selected_squirrel: SquirrelNode = null
signal combat_requested(squirrel: SquirrelNode)





func _ready():
	button_combat.pressed.connect(_on_button_combat_pressed)
	button_cancel.pressed.connect(_on_button_cancel_pressed)
	# dans _ready() par exemple
	for sn in $tree_container.get_children():
		sn.show_info_requested.connect(_on_squirrel_info_requested)

		if sn is SquirrelNode:
			for path in sn.descendants:
				var descendant = sn.get_node_or_null(path)
				if descendant:
					var line = draw_link(sn, descendant)
					sn.descendant_lines[descendant] = line
					
					

			
	
func _on_button_combat_pressed():
	if selected_squirrel:
		print("Combat demandé contre :", selected_squirrel.squirrel_name)
		emit_signal("combat_requested", selected_squirrel)
		
		genealogy_tree.visible = false
		
		
	else:
		print("Aucun écureuil sélectionné !")
	
	
func _on_button_cancel_pressed():
	if selected_squirrel:
		selected_squirrel = null
	
	info_panel.visible = false	
	
	print("cancel")				
			
func _on_squirrel_info_requested(sn: SquirrelNode):
	print("yup")
	selected_squirrel = sn  # ← Stocke le node sélectionné
	name_label.text = sn.squirrel_name
	squirrel_avatar.texture = sn.squirrel_avatar
	description.text = sn.description
	print(sn.avatar)
	info_panel.visible = true
	
	
func draw_link(from_node: SquirrelNode, to_node: SquirrelNode) -> Line2D:
	var line = Line2D.new()
	line.default_color = Color("#fbba72")
	line.width = 3.0

	var from_pos = from_node.connection_point_start.get_global_position()
	var to_pos = to_node.connection_point_end.get_global_position()

	line.add_point(from_pos)
	line.add_point(to_pos)

	add_child(line)
	return line
