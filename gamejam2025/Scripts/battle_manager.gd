extends Node

const DEFAULT_CARD_MOVE_SPEED = 0.1
const CARD_MOVE_SPEED = 0.3
const MAX_MANA = 5.0
const CARD_TYPE_OFFENSE = "Offense"
const CARD_TYPE_DEFENSE = "Defense"
const ennemyMoves = [
	{"type": "Attack", "damage": 10},
	{"type": "Attack", "damage": 15},
	{"type": "Attack", "damage": 20},
	{"type": "Defense", "damage": 5}
]

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var deck: Node2D = $"../Deck"
@onready var discard_pile_reference: Node2D = $"../DiscardPile"
@onready var card_manager: Node2D = $"../CardManager"
@onready var mana_counter: Node2D = $"../ManaCounter"
@onready var button_show_tree = $button_show_tree
@onready var genealogy_tree = $"../GenealogyTree"
@onready var battle_background = $"../BattleBackground"
@onready var squirrel_enemy: Node2D = $"../SquirrelEnemy"
@onready var end_turn_button: Button = $"../EndTurnButton"
@onready var player: Node2D = $"../Player"
@onready var enemy_shield: Sprite2D = $"../EnemyShield"
@onready var enemy_sword: Sprite2D = $"../EnemySword"

var discard_pile = []
var card_being_played
var current_mana
var allies = []
var ennemyNextMove


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mana_counter.get_node("Counter").text = str(MAX_MANA) + "/" + str(MAX_MANA)
	current_mana = MAX_MANA
	
	button_show_tree.pressed.connect(_on_button_show_tree_pressed)
	genealogy_tree.combat_requested.connect(_on_combat_requested)
	
	setNextMove()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play_a_card(card):
	#print("Play a card")
	#print(card)
	# Check si on peut jouer la carte (assez de mana)
	if card.mana <= current_mana:
		card_being_played = card
		# Retirer la mana
		current_mana = max(0, current_mana - card.mana)
		mana_counter.get_node("Counter").text = str(current_mana) + "/" + str(MAX_MANA)
		# Ajouter la carte dans la DiscardPile
		discard_pile.append(card)
		# Enlever la carte du player_hand
		player_hand.remove_card_from_hand(card)
		# Enlever la carte du deck
		deck.player_deck.erase(card)
		# Faire l'effet
		if card.card_type == CARD_TYPE_OFFENSE:
			squirrel_enemy.reduceHealth(card.damage)
		elif card.card_type == CARD_TYPE_DEFENSE:
			player.addDefense(card.armor)
			
		# Déplacer la carte dans la DiscardPile
		var new_pos = discard_pile_reference.position
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)
		tween.connect("finished", on_tween_finished)
		
	# Sinon, remettre la carte dans la main
	else:
		player_hand.add_card_to_hand(card, DEFAULT_CARD_MOVE_SPEED)
	

func on_tween_finished():
	discard_pile_reference.get_node("CardCounter").text = str(discard_pile.size())
	# Détruire la carte
	card_being_played.queue_free()
	
	

func _on_button_show_tree_pressed():
	print("Show Tree")	
	genealogy_tree.visible = true
	battle_background.modulate.a = 0.2
	mana_counter.visible = false
	deck.visible = false
	discard_pile_reference.visible = false
	card_manager.visible = false
	card_manager.set_physics_process(false)
	card_manager.set_process(false)
	squirrel_enemy.visible = false
	player.visible = false
	
	
func _on_combat_requested(squirrel: SquirrelNode):
	print("BattleManager a reçu :", squirrel.squirrel_name)
	
	squirrel_enemy.setEnnemy(squirrel)

	
	
	
	
	genealogy_tree.visible = false
	battle_background.modulate.a = 1
	mana_counter.visible = true
	deck.visible = true
	discard_pile_reference.visible = true
	card_manager.visible = true
	card_manager.set_physics_process(true)
	card_manager.set_process(true)
	squirrel_enemy.visible = true
	player.visible = true
	

func on_end_turn_pressed():
	end_turn_button.visible = false
	
	empty_player_hand()
	
	attack_allies()

	await get_tree().create_timer(1).timeout
	attack_enemies()

	await get_tree().create_timer(1).timeout
	current_mana = MAX_MANA
	mana_counter.get_node("Counter").text = str(current_mana) + "/" + str(MAX_MANA)

	end_turn_button.visible = true
	print(discard_pile)
	discard_pile.clear()
	discard_pile_reference.get_node("CardCounter").text = str(discard_pile.size())
	deck.draw_all_cards()

func attack_allies():
	for ally in allies:
		squirrel_enemy.reduceHealth(10)

func attack_enemies():
	if ennemyNextMove.type == "Attack":
		player.reduceHealth(ennemyNextMove.damage * squirrel_enemy.damageMultiplier)
	else:
		squirrel_enemy.defense = ennemyNextMove.damage
	setNextMove()

func setNextMove():
	ennemyNextMove = ennemyMoves.pick_random()
	if ennemyNextMove.type == "Attack":
		enemy_shield.visible = false
		enemy_sword.visible = true
	if ennemyNextMove.type == "Defense":
		enemy_shield.visible = true
		enemy_sword.visible = false

func _on_end_turn_button_pressed() -> void:
	on_end_turn_pressed()
	
func empty_player_hand():
	#print("Empty!!!")
	#print(player_hand.player_hand)
	#var real_player_hand = player_hand.player_hand
	if player_hand.player_hand.size() > 0:
		for i in player_hand.player_hand:
			# Déplacer la carte dans la DiscardPile
			var new_pos = discard_pile_reference.position
			var tween = get_tree().create_tween()
			tween.tween_property(i, "position", new_pos, CARD_MOVE_SPEED)
			tween.connect("finished", on_tween_finished_empty_hand)
			discard_pile.append(i)
	
func on_tween_finished_empty_hand():
	discard_pile_reference.get_node("CardCounter").text = str(discard_pile.size())
	for card in player_hand.player_hand:
		card.queue_free()
	player_hand.player_hand.clear()
