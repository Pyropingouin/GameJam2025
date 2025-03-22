extends Node2D

const CARD_COLLISION_MASK = 1

@onready var input_manager: Node2D = $"../InputManager"

var screen_size
var card_being_dragged

func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager.connect("left_mouse_button_released", on_left_click_released)


func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		
		# Clamp permet d'empêcher les cartes de sortir de l'écran
		card_being_dragged.position = Vector2(clamp(mouse_position.x, 0, screen_size.x), 
			clamp(mouse_position.y, 0, screen_size.y))

func on_left_click_released():
	if card_being_dragged:
		finish_drag()

#func raycast_check_for_card():
	#var space_state = get_world_2d().direct_space_state
	#var parameters = PhysicsPointQueryParameters2D.new()
	#parameters.position = get_global_mouse_position()
	#parameters.collision_mask = CARD_COLLISION_MASK
	#parameters.collide_with_areas = true
	#
	#var result = space_state.intersect_point(parameters)
	#if result.size() > 0:
		#return get_card_with_highest_z_index()
	#return null

func get_card_with_highest_z_index():
	pass

func card_clicked(card):
	start_drag(card)

func start_drag(card):
	card_being_dragged = card
	print("Start drag")

func finish_drag():
	print("Finish drag")
	card_being_dragged = null

func draw_card():
	pass
