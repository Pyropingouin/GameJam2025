class_name SquirrelNode
extends Panel

@export var squirrel_name: String = "Squirrel McNutty"
@export var squirrel_avatar: Texture2D
@export var hp: int = 12
@export var description: String

@export var descendants: Array[NodePath]  # Tu pourras assigner les descendants dans l'éditeur

@onready var name_label: Label = $name_label
@onready var avatar: TextureRect = $avatar
@onready var button = $Button
@onready var button2 = $Button2
@onready var connection_point_start: Node2D = $connection_point_start
@onready var connection_point_end: Node2D = $connection_point_end

var descendant_lines: Dictionary = {}



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
	print("Bouton 2 cliqué — on supprime les descendants de", squirrel_name)
	
	var flash_count = 3
	var flash_duration = 0.2
	var total_flash_time = flash_count * flash_duration * 2

	# Lancer le flash pour chaque descendant
	for path in descendants:
		var descendant = get_node_or_null(path)
		if descendant and descendant is CanvasItem:
			flash_node(descendant, flash_count, flash_duration)
			
			
	# Faire flasher ce noeud lui-même
	flash_node(self, flash_count, flash_duration)		

	# Attendre la fin du flash avant de les supprimer
	await get_tree().create_timer(total_flash_time).timeout

	for path in descendants:
		var descendant = get_node_or_null(path)
		if descendant:
			descendant.queue_free()
			
			
	queue_free()		

			
			
			
			
func flash_node(node: CanvasItem, times := 3, flash_duration := 0.15):
	var tween = create_tween()
	for i in range(times):
		tween.tween_property(node, "modulate", Color(1, 0.2, 0.2), flash_duration)
		tween.tween_property(node, "modulate", Color(1, 1, 1), flash_duration)		
		
			
