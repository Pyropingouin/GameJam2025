extends Node2D

signal back_to_menu_button_pressed

func _on_back_to_menu_pressed() -> void:
	emit_signal("back_to_menu_button_pressed")
