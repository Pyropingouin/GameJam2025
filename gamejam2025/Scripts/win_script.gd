extends Node

@onready var avatar = $avatar
@onready var button = $button
@onready var dialog = $dialog
@onready var name_label = $name
@onready var genealogy_tree = $"../GenealogyTree"

var defeated_squirrel: SquirrelNode


func _ready():
	button.pressed.connect(_on_button_next_pressed)

func _on_button_next_pressed():
	print("next")
	genealogy_tree.info_panel.visible = false
	if is_instance_valid(defeated_squirrel):
		defeated_squirrel._on_button2_pressed()

	
func set_squirrel(squirrel: SquirrelNode) -> void:
	defeated_squirrel = squirrel
	$avatar.texture = squirrel.squirrel_avatar
	$name.text = squirrel.squirrel_name
	$dialog.text = squirrel.win_text	
	
