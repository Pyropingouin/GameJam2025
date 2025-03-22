extends Node2D

signal hovered
signal hovered_off

@onready var card_manager: Node2D = $"../CardManager"

func _ready() -> void:
	card_manager.connect_enemy_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_mouse_entered() -> void:
	#print("Hover squirrel")
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	#print("Hover off squirrel")
	emit_signal("hovered_off", self)
