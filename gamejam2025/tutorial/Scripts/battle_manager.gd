extends Node

const CARD_SMALLER_SCALE = 0.6
const CARD_MOVE_SPEED = 0.2
const STARTING_HEALTH = 10
const BATTLE_POS_OFFSET = 25

var battle_timer
var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []
var player_cards_that_attacked_this_turn = []
var player_health
var opponent_health
var is_opponents_turn = false
var player_is_attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_monster_card_slots.append($"../CardSlots/OpponentCardSlot1")
	empty_monster_card_slots.append($"../CardSlots/OpponentCardSlot2")
	empty_monster_card_slots.append($"../CardSlots/OpponentCardSlot3")
	empty_monster_card_slots.append($"../CardSlots/OpponentCardSlot4")
	empty_monster_card_slots.append($"../CardSlots/OpponentCardSlot5")
	
	player_health = STARTING_HEALTH
	$"../PlayerHealth".text = str(player_health)
	opponent_health = STARTING_HEALTH
	$"../OpponentHealth".text = str(opponent_health)

func _on_end_turn_button_pressed() -> void:
	is_opponents_turn = true
	$"../CardManager".unselect_selected_monster()
	player_cards_that_attacked_this_turn = []
	opponent_turn()

func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	await wait(1)
	
	# If can draw a card, draw then wait 1 second
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		
		await wait(1.0)
	
	# Check if any free slots, and play monster with highest attack if so
	if empty_monster_card_slots.size() != 0:
		# Try play card and wait 1 sec if played
		await try_play_card_with_highest_attack()
	
	# Try attack
	# Check if at least 1 card on opponent battlefield
	if opponent_cards_on_battlefield.size() != 0:
		# Create a new arrau with all the opponent cards to loop through
		var enemy_cards_to_attack = opponent_cards_on_battlefield.duplicate()
		# Each opponent attacks
		for card in enemy_cards_to_attack:
			# If at least 1 card on player field
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "Opponent")
			else:
				# Perform direct attack
				await direct_attack(card, "Opponent")
				
	
	# End turn
	end_opponent_turn()

func direct_attack(attacking_card, attacker):
	print("Direct attack")
	var new_pos_y
	if attacker == "Opponent":
		new_pos_y = 1080
	else:
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		player_is_attacking = true
		new_pos_y = 0
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	# Attack directement en face
	# var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	# Attack vers le centre
	var new_pos = Vector2(960, new_pos_y)
	
	# Lorsque la card attaque, elle passe au-dessus de tout
	attacking_card.z_index = 5
	
	# Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	
	if attacker == "Opponent":
		# Deal damage to player
		player_health = max(0, player_health - attacking_card.attack)
		$"../PlayerHealth".text = str(player_health)
	else:
		# Deal damage to opponent
		opponent_health = max(0, opponent_health - attacking_card.attack)
		$"../OpponentHealth".text = str(opponent_health)
	
	# Animate card back to position
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	# Reset le z index
	attacking_card.z_index = 0
	
	await wait(1.0)
	
	if attacker == "Player":
		player_is_attacking = false
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
	
func attack(attacking_card, defending_card, attacker):
	print("Attack")
	
	if attacker == "Player":
		player_is_attacking = true
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		$"../CardManager".selected_monster = null
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	# Lorsque la card attaque, elle passe au-dessus de tout
	attacking_card.z_index = 5
	
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	# Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	
	# Animate card back to position
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	# Card damage
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("Health").text = str(defending_card.health)
	
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait(1.0)
	
	# Reset le z index
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	
	# Destroy cards if health is 0
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
		card_was_destroyed = true
	if defending_card.health == 0:
		if attacker == "Player":
			destroy_card(defending_card, "Opponent")
		else:
			destroy_card(defending_card, "Player")
		card_was_destroyed = true
	
	if card_was_destroyed:
		await wait(1.0)
		
	if attacker == "Player":
		player_is_attacking = false
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
	
func destroy_card(card, card_owner):
	# Move card to discard pile
	# Remove card from any relevant arrays e.g. player_cards_on_battlefield
	var new_pos
	if card_owner == "Player":
		card.defeated = true
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = $"../PlayerDiscardPile".position
		if card in player_cards_on_battlefield:
			player_cards_on_battlefield.erase(card)
		card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		new_pos = $"../OpponentDiscardPile".position
		if card in opponent_cards_on_battlefield:
			opponent_cards_on_battlefield.erase(card)
	
	card.card_slot_card_is_in.card_in_slot = false
	card.card_slot_card_is_in = null
	
	# Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)
	
func try_play_card_with_highest_attack():
	# Get random empty card slot to play the card in
	var opponent_hand = $"../OpponentHand".opponent_hand
	
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	
	#var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size() - 1)]
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	
	# Play the card in hand with highest attack
	# Start by assuming the first card in hand has higher attack
	var current_card_with_highest_attack = opponent_hand[0]
	
	for card in opponent_hand:
		if card.attack > current_card_with_highest_attack.attack:
			current_card_with_highest_attack = card
	
	# Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(current_card_with_highest_attack, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(current_card_with_highest_attack, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	
	current_card_with_highest_attack.get_node("AnimationPlayer").play("card_flip")
	
	# Remove the card from opponent's hand
	$"../OpponentHand".remove_card_from_hand(current_card_with_highest_attack)
	
	current_card_with_highest_attack.card_slot_card_is_in = random_empty_monster_card_slot
	
	opponent_cards_on_battlefield.append(current_card_with_highest_attack)
	
	await wait(1.0)

func opponent_card_selected(defending_card):
	var attacking_card = $"../CardManager".selected_monster
	if attacking_card:
		if defending_card in opponent_cards_on_battlefield:
			if player_is_attacking == false:
				$"../CardManager".selected_monster = null
				attack(attacking_card, defending_card, "Player")

func end_opponent_turn():
	# Reset player deck draw
	$"../Deck".reset_draw()
	
	# Reset played monster this turn
	$"../CardManager".reset_played_monster_this_turn()
	
	is_opponents_turn = false
	
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false

func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout
