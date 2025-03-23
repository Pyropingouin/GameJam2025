extends Node

const DEFAULT_CARD_MOVE_SPEED = 0.1
const CARD_MOVE_SPEED = 0.3
const MAX_MANA = 5.0
const CARD_TYPE_OFFENSE = "Offense"
const ennemyMoves = [
	{"type": "Attack", "damage": 10},
	{"type": "Attack", "damage": 15},
	{"type": "Attack", "damage": 20},
	{"type": "Defense", "damage": 0}
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
@onready var win_screen = $"../WinScreen"
@onready var win_scree_final = $"../WinScreenFinal"




var discard_pile = []
var card_being_played
var current_mana
var allies = []
var ennemyNextAttack
var current_enemy: SquirrelNode



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mana_counter.get_node("Counter").text = str(MAX_MANA) + " / " + str(MAX_MANA)
	current_mana = MAX_MANA
	
	button_show_tree.pressed.connect(_on_button_show_tree_pressed)
	genealogy_tree.combat_requested.connect(_on_combat_requested)
	squirrel_enemy.died.connect(_on_squirrel_enemy_died)
	win_screen.get_node("button").pressed.connect(_on_button_show_tree_pressed)
	
	setNextAttack()
	
	################# TEST AVEC ECUREIL DE DÉBUT
	var test_squirrel = preload("res://Scenes/squirrel_node.tscn").instantiate()
	test_squirrel.squirrel_name = "Test McNutty"
	test_squirrel.squirrel_avatar = preload("res://Assets/icon.svg")
	test_squirrel.description = "Un écureuil redoutable de test."
	test_squirrel.hp = 20
	
	# Stocker dans current_enemy pour simuler un vrai
	current_enemy = test_squirrel
	
	
	##################### FIN DU TEST AVEC ÉCUREIL DÉBUT

	
	print(ennemyNextAttack)

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
		mana_counter.get_node("Counter").text = str(current_mana) + " / " + str(MAX_MANA)
		# Ajouter la carte dans la DiscardPile
		discard_pile.append(card)
		# Enlever la carte du player_hand
		player_hand.remove_card_from_hand(card)
		# Enlever la carte du deck
		deck.player_deck.erase(card)
		# Faire l'effet
		if card.card_type == CARD_TYPE_OFFENSE:
			squirrel_enemy.reduceHealth(card.damage)
			
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
	
func _on_squirrel_enemy_died():
	print("L'ennemi est mort ! 🎉")
	win_screen.set_squirrel(current_enemy) 
	
	if current_enemy.squirrel_name == "chef":
		print("win")
		battle_background.visible = false
		mana_counter.visible = false
		deck.visible = false
		discard_pile_reference.visible = false
		card_manager.visible = false
		card_manager.set_physics_process(false)
		card_manager.set_process(false)
		squirrel_enemy.visible = false
		player.visible = false
		end_turn_button.visible = false
		win_scree_final.visible = true
	
		
		
	else:		
		battle_background.modulate.a = 0.2
		mana_counter.visible = false
		deck.visible = false
		discard_pile_reference.visible = false
		card_manager.visible = false
		card_manager.set_physics_process(false)
		card_manager.set_process(false)
		squirrel_enemy.visible = false
		player.visible = false
		end_turn_button.visible = false
		win_screen.visible = true
	
	
	
	

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
	end_turn_button.visible = false
	win_screen.visible = false
	
	
func _on_combat_requested(squirrel: SquirrelNode):
	print("BattleManager a reçu :", squirrel.squirrel_name)
	current_enemy = squirrel  
	squirrel_enemy.setEnnemy(squirrel)
	player.resetPlayer()



	
	
	
	
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
	end_turn_button.visible = true
	

func on_end_turn_pressed():
	end_turn_button.visible = false
	
	attack_allies()

	await get_tree().create_timer(1).timeout
	attack_enemies()

	await get_tree().create_timer(1).timeout
	current_mana = MAX_MANA
	mana_counter.get_node("Counter").text = str(current_mana) + " / " + str(MAX_MANA)

	end_turn_button.visible = true

func attack_allies():
	for ally in allies:
		squirrel_enemy.reduceHealth(10)

func attack_enemies():
		print(ennemyNextAttack.damage * squirrel_enemy.damageMultiplier)
		print(ennemyNextAttack.damage)
		print(squirrel_enemy.damageMultiplier)
		player.reduceHealth(ennemyNextAttack.damage * squirrel_enemy.damageMultiplier)
		setNextAttack()

func setNextAttack():
	ennemyNextAttack = ennemyMoves.pick_random()

func _on_end_turn_button_pressed() -> void:
	on_end_turn_pressed()
	
	
