class_name SquirrelNode
extends Panel

@export var squirrel_name: String = "Squirrel McNutty"
@export var squirrel_avatar: Texture2D
@export var hp: int = 12

@export var descendants: Array[NodePath]  # Tu pourras assigner les descendants dans l'éditeur

@onready var name_label: Label = $name_label
@onready var avatar: TextureRect = $avatar
@onready var button = $Button
@onready var button2 = $Button2


signal show_info_requested(squirrel: SquirrelNode)

func _ready():
	name_label.text = squirrel_name
	avatar.texture = squirrel_avatar
	button.pressed.connect(_on_button_pressed)
	button2.pressed.connect(_on_button2_pressed)

func _on_button_pressed():
	print("Squirrel sélectionné :", squirrel_name)
	print(self)
	emit_signal("show_info_requested", self)


func _on_button2_pressed():
	print("Bouton 2 cliqué — on cache les descendants de", squirrel_name)
	for path in descendants:
		var descendant = get_node_or_null(path)
		if descendant:
			descendant.visible = false
			
			
