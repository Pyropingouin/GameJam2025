extends Node2D

signal start_game_button_pressed
signal enter_credits_button_pressed

func _on_start_game_button_pressed() -> void:
	emit_signal("start_game_button_pressed")


func _on_credits_button_pressed() -> void:
	emit_signal("enter_credits_button_pressed")
