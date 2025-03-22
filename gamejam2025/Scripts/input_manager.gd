extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released
signal right_mouse_button_clicked

const CARD_COLLISION_MASK = 1
const DECK_COLLISION_MASK = 2
const ENEMY_COLLISTION_MASK = 4

@onready var card_manager: Node2D = $"../CardManager"
@onready var deck: Node2D = $"../Deck"

func _ready() -> void:
	pass # Replace with function body.
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		emit_signal("right_mouse_button_clicked")

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		
		if result_collision_mask == CARD_COLLISION_MASK:
			# Card clicked
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager.card_clicked(card_found)
		#elif result_collision_mask == DECK_COLLISION_MASK:
			## Deck clicked
			#deck.draw_card()
		elif result_collision_mask == ENEMY_COLLISTION_MASK:
			pass
