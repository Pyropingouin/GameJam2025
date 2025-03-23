extends Node

const DEFAULT_CARD_MOVE_SPEED = 0.1
const ATTACK_MOVE_SPEED = 0.1
const CARD_MOVE_SPEED = 0.3
const MAX_MANA = 5.0
const CARD_TYPE_OFFENSE = "Offense"
const CARD_TYPE_DEFENSE = "Defense"
const ennemyMoves = [
	{"type": "Attack", "damage": 5},
	{"type": "Attack", "damage": 10},
	{"type": "Attack", "damage": 15},
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
@onready var win_screen = $"../WinScreen"
@onready var win_scree_final = $"../WinScreenFinal"
@onready var animations: Node2D = $"../Animations"
@onready var lose_screen = $"../LoseScreen"
@onready var shield: Sprite2D = $HealthBar/Shield
@onready var shield_text: RichTextLabel = $HealthBar/ShieldText
@onready var audio_manager: Node2D = $"../AudioManager"

var discard_pile = []
var card_being_played
var current_mana
var allies = []
var ennemyNextMove
var current_enemy: SquirrelNode
var player_pos_copy
var enemy_pos_copy



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_manager.get_node("Forest").play()
	audio_manager.get_node("Squirrel").play()
	
	animations.get_node("Claw").visible = false
	animations.get_node("Tail").visible = false
	animations.get_node("Shield").visible = false
	animations.get_node("ShieldEnemy").visible = false

	mana_counter.get_node("Counter").text = str(MAX_MANA) + "/" + str(MAX_MANA)
	current_mana = MAX_MANA
	
	button_show_tree.pressed.connect(_on_button_show_tree_pressed)
	genealogy_tree.combat_requested.connect(_on_combat_requested)
	squirrel_enemy.died.connect(_on_squirrel_enemy_died)
	win_screen.get_node("button").pressed.connect(_on_button_show_tree_pressed)
	player.died.connect(_on_player_died)

	setNextMove()
	################# TEST AVEC ECUREIL DE DÉBUT
	var test_squirrel = preload("res://Scenes/squirrel_node.tscn").instantiate()
	test_squirrel.squirrel_name = "Test McNutty"
	test_squirrel.squirrel_avatar = preload("res://Assets/icon.svg")
	test_squirrel.description = "Un écureuil redoutable de test."
	test_squirrel.hp = 20
	# Stocker dans current_enemy pour simuler un vrai
	current_enemy = test_squirrel
	##################### FIN DU TEST AVEC ÉCUREIL DÉBUT
	
	
	
	
	# Si on a des allies, les faire apparaitre

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play_a_card(card):
	#print("Play a card")
	#print(card)
	# Check si on peut jouer la carte (assez de mana)
	if card.mana <= current_mana:
		audio_manager.get_node("PlayingCard").play()
		
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
		
		if card_being_played.card_type == CARD_TYPE_OFFENSE:
			player_pos_copy = player.position
			print(player_pos_copy)
			var new_player_pos = Vector2(player_pos_copy.x + 60, player_pos_copy.y)
			#var new_player_pos = Vector2(squirrel_enemy.position.x - 100, squirrel_enemy.position.y)
			var tween2 = get_tree().create_tween()
			tween2.tween_property(player, "position", new_player_pos, ATTACK_MOVE_SPEED)
			tween2.connect("finished", on_tween_attack_finished)
		elif card_being_played.card_type == CARD_TYPE_DEFENSE:
			animations.get_node("Shield").visible = true
			animations.get_node("AnimationPlayer").play("shield_buff")
	# Sinon, remettre la carte dans la main
	else:
		player_hand.add_card_to_hand(card, DEFAULT_CARD_MOVE_SPEED)
	
func on_tween_attack_finished():
	#print("Atack")
	if card_being_played.card_name == "Griffe":
		animations.get_node("Claw").visible = true
		animations.get_node("AnimationPlayer").play("claw_hit")
	elif card_being_played.card_name == "Tail":
		animations.get_node("Tail").visible = true
		animations.get_node("AnimationPlayer").play("tail_hit")
	print(player.position)
	var tween3 = get_tree().create_tween()
	tween3.tween_property(player, "position", player_pos_copy, ATTACK_MOVE_SPEED)

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
		
	empty_player_hand()
	
	discard_pile.clear()
	discard_pile_reference.get_node("CardCounter").text = str(discard_pile.size())
	
func _on_player_died():
	print("💀 Le joueur est mort ! GAME OVER")
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
	lose_screen.visible = true
	

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
	enemy_shield.visible = false
	enemy_sword.visible = false
	
	
func _on_combat_requested(squirrel: SquirrelNode):
	audio_manager.get_node("EngageBattle").play()
	
	print("BattleManager a reçu :", squirrel.squirrel_name)
	current_enemy = squirrel  
	squirrel_enemy.setEnnemy(squirrel)
	setNextMove()
	
	player.resetPlayer()
	current_mana = MAX_MANA
	mana_counter.get_node("Counter").text = str(MAX_MANA) + "/" + str(MAX_MANA)
	
	deck.draw_all_cards()
	
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
	
	empty_player_hand()
	
	attack_allies()

	await get_tree().create_timer(1).timeout
	attack_enemies()

	await get_tree().create_timer(1).timeout
	current_mana = MAX_MANA
	mana_counter.get_node("Counter").text = str(current_mana) + "/" + str(MAX_MANA)

	end_turn_button.visible = true
	#print(discard_pile)
	discard_pile.clear()
	discard_pile_reference.get_node("CardCounter").text = str(discard_pile.size())
	deck.draw_all_cards()

func attack_allies():
	for ally in allies:
		squirrel_enemy.reduceHealth(10)

func attack_enemies():
	if ennemyNextMove.type == "Attack":
		if squirrel_enemy.squirrel_type == "Normal":
			audio_manager.get_node("EnemyNormalAttack").play()
		elif squirrel_enemy.squirrel_type == "Baton":
			audio_manager.get_node("EnemyAutre").play()
		elif squirrel_enemy.squirrel_type == "Hochet":
			audio_manager.get_node("EnemyHochet").play()
		elif squirrel_enemy.squirrel_type == "Slingshot":
			audio_manager.get_node("EnemySlingshot").play()
		
		enemy_pos_copy = squirrel_enemy.position
		print(enemy_pos_copy)
		var new_pos = Vector2(enemy_pos_copy.x - 60, enemy_pos_copy.y)
		print(new_pos)
		var tween = get_tree().create_tween()
		tween.tween_property(squirrel_enemy, "position", new_pos, ATTACK_MOVE_SPEED)
		tween.connect("finished", on_tween_attack_enemy_finished)
		player.reduceHealth(ennemyNextMove.damage * squirrel_enemy.damageMultiplier)
	else:
		animations.get_node("ShieldEnemy").visible = true
		animations.get_node("AnimationPlayer").play("shield_buff_enemy")
		squirrel_enemy.defense = ennemyNextMove.damage
	setNextMove()
	
	
	print("damage", ennemyNextMove.damage)
	print("mult", squirrel_enemy.damageMultiplier)

func on_tween_attack_enemy_finished():
	var tween2 = get_tree().create_tween()
	tween2.tween_property(squirrel_enemy, "position", enemy_pos_copy, ATTACK_MOVE_SPEED)

func setNextMove():
	ennemyNextMove = ennemyMoves.pick_random()
	if ennemyNextMove.type == "Attack":
		enemy_shield.visible = false
		enemy_sword.visible = true
	if ennemyNextMove.type == "Defense":
		enemy_shield.visible = true
		enemy_sword.visible = false
		squirrel_enemy.setDefense(ennemyNextMove.damage)

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
