extends Node

@onready var avatar = $avatar
@onready var button = $button
@onready var dialog = $dialog
@onready var name_label = $name

func _ready():
	button.pressed.connect(_on_button_next_pressed)

func _on_button_next_pressed():
	print("next")
	
func set_squirrel(squirrel: SquirrelNode) -> void:
	$avatar.texture = squirrel.squirrel_avatar
	$name.text = squirrel.squirrel_name
	$dialog.text = squirrel.win_text	
	
