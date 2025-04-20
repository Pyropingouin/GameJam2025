extends Node2D

signal restart_button_pressed

func _on_restart_button_pressed() -> void:
	emit_signal("restart_button_pressed")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
