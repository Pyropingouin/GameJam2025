extends Node2D

const CARD_COLLISION_MASK = 1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGGER_SCALE = 1.05
const DEFAULT_CARD_MOVE_SPEED = 0.1

@onready var input_manager: Node2D = $"../InputManager"
@onready var player_hand: Node2D = $"../PlayerHand"

var screen_size
var card_being_dragged
var is_hovering_on_card

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

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collision_mask = CARD_COLLISION_MASK
	parameters.collide_with_areas = true
	
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# Si 2 cartes se chevauche, prendre celle du devant
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	var card_with_highest_z = cards[0].collider.get_parent()
	var highest_z_index = card_with_highest_z.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			card_with_highest_z = current_card
			highest_z_index = current_card.z_index
	
	return card_with_highest_z

func card_clicked(card):
	start_drag(card)

func start_drag(card):
	card_being_dragged = card
	print("Start drag")

func finish_drag():
	print("Finish drag")
	
	# Si on ne sélectionne pas l'ennemi?
	var jambon = false
	if !jambon:
		player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	
	card_being_dragged = null

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	print("hovered")
	# Hover seulement sur une carte
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card): 
	print("hovered off")
	if !card_being_dragged:
		highlight_card(card, false)
		
		# Check si on hover directement sur une autre carte
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		# Mettre la carte au-devant
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1
