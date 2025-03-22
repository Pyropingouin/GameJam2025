extends Node2D

# On pourrait gérer le hover ici, mais on préfère dans CardManager (donc emit)
signal hovered
signal hovered_off

var hand_position
var card_slot_card_is_in
var card_type
var health
var attack
var defeated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get le CardManager
	# All cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	# print("hovered")
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	# print("hovered off")
	emit_signal("hovered_off", self)
