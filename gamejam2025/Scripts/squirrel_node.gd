extends Panel

@export var squirrel_name: String = "Squirrel McNutty"
@export var squirrel_avatar: Texture2D

@onready var name_label: Label = $name_label
@onready var avatar: TextureRect = $avatar
@onready var button = $Button

func _ready():
	name_label.text = squirrel_name
	avatar.texture = squirrel_avatar
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	print("Squirrel sélectionné :", name_label.text)
