extends Node2D

signal hovered
signal hovered_off

var hand_position
var damage
var armor
var heal
var card_effect
var card_type

func _ready() -> void:
	# !! Toutes les cartes doivent être enfant de CardManager !!
	get_parent().connect_card_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	print("1")
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	print("2")
	emit_signal("hovered_off", self)
