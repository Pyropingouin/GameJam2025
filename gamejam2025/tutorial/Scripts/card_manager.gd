extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGGER_SCALE = 1.05
const CARD_SMALLER_SCALE = 0.6

var screen_size
var card_being_dragged
var is_hovering_on_card
var player_hand_reference
var played_monster_card_this_turn = false
var selected_monster

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		# Clamp: Empêcher les cartes de sortir du screen
		card_being_dragged.position = Vector2(clamp(mouse_position.x, 0, screen_size.x), 
			clamp(mouse_position.y, 0, screen_size.y))

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			## print("Left click")
			## Raycast check for card
			#var card = raycast_check_for_card()
			#if card:
				#start_drag(card)
		#else:
			## print("Left click released")
			#if card_being_dragged:
				#finish_drag()

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# print(result[0].collider.get_parent())
		# return result[0].collider.get_parent()
		
		# Si 2 cartes se chevauchent, prendre celle du devant
		return get_card_with_highest_z_index(result)
	return null

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func get_card_with_highest_z_index(cards):
	# Assume the first card in cards has the highest z index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# Loop through the rest of the cards checking for a higher z index
	for i in range(1, cards.size()):
		var current_card = cards[1].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_left_click_released():
	# print("Card manager left mouse released signal")
	if card_being_dragged:
		finish_drag()

func on_hovered_over_card(card):
	# print("hovered")
	if card.card_slot_card_is_in:
		return
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !card.defeated:
		# Check if card is NOT in card slot AND NOT being dragged
		if !card.card_slot_card_is_in && !card_being_dragged:
			# If not dragging
			# print("hovered_off")
			# is_hovering_on_card = false
			highlight_card(card, false)
				
			# Check if hovered off card straight on to another card
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered, true)
			else:
				is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1

func card_clicked(card):
	if card.card_slot_card_is_in:
		if $"../BattleManager".is_opponents_turn == false:
			if $"../BattleManager".player_is_attacking == false:
				# Card is on battlefield
				if card not in $"../BattleManager".player_cards_that_attacked_this_turn:
					if $"../BattleManager".opponent_cards_on_battlefield.size() == 0:
						$"../BattleManager".direct_attack(card, "Player")
						return
					else:
						select_card_for_battle(card)
	else:
		start_drag(card)
	
func select_card_for_battle(card):
	# Toggle selected card
	if selected_monster:
		if selected_monster == card:
			card.position.y += 20
			selected_monster = null
		else:
			selected_monster.position.y += 20
			selected_monster = card
			card.position.y -= 20
	else:
		selected_monster = card
		card.position.y -= 20

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
	
func finish_drag():
	card_being_dragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		# Check if card is the same type as the card slot
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			if !played_monster_card_this_turn:
				played_monster_card_this_turn = true
				# Card dropped in card slot
				card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
				card_being_dragged.z_index = -1
				is_hovering_on_card = false
				card_being_dragged.card_slot_card_is_in = card_slot_found
				
				player_hand_reference.remove_card_from_hand(card_being_dragged)
				# Card dropped in empty card slot
				card_being_dragged.position = card_slot_found.position
				# Disabled l'interaction avec la carte dans le slot
				# card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
				# Mettre le slot comme étant occupé
				card_slot_found.card_in_slot = true
				card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
				
				$"../BattleManager".player_cards_on_battlefield.append(card_being_dragged)
				
				card_being_dragged = null
				return
		#else:
			#player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
		
	# Si on n'est pas dans un slot, on snap back la carte dans la main
	#else:
		#player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null
	
func unselect_selected_monster():
	if selected_monster:
		selected_monster.position.y += 20
		selected_monster = null

func reset_played_monster_this_turn():
	played_monster_card_this_turn = false
