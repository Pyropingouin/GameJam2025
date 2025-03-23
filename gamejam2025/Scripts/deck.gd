extends Node2D

const HAND_SIZE = 4
const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.5

@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"
@onready var battle_manager: Node = $"../BattleManager"
@onready var discard_pile_reference: Node2D = $"../DiscardPile"

var player_deck = ["CarteGland", "CarteQueue", "CarteGriffe", "CarteQueue", "CarteGriffe"]
var player_deck_copy = ["CarteGland", "CarteQueue", "CarteGriffe", "CarteQueue", "CarteGriffe"]
var card_database_reference

func _ready() -> void:
	player_deck.shuffle()
	$CardCounter.text = str(player_deck.size())
	
	card_database_reference = preload("res://Scripts/card_database.gd")
	
	# Main de départ
	#for i in range(HAND_SIZE):
		#draw_card()
	draw_all_cards()

func draw_card():
	#print("Draw card")
	
	# Si on a plus de cartes dans le deck
	#if player_deck.size() == 0:
		#print("Vide")
		#
		## Aller chercher la discard_pile
		#var discard_pile = battle_manager.discard_pile
		#print(battle_manager.discard_pile)
		## Mettre la discard_pile dans le player_deck
		#player_deck = discard_pile.duplicate()
		#print(player_deck)
		## Vider la discard_pile
		#battle_manager.discard_pile.clear()
		## Mélanger le player_deck
		#player_deck.shuffle()
		## Update les compteurs de deck
		#$CardCounter.text = str(player_deck.size())
		#discard_pile_reference.get_node("CardCounter").text = str(battle_manager.discard_pile.size())
		#print(player_deck)
		#return
	
	#player_deck = player_deck_copy.duplicate()
	#player_deck.shuffle()
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	$CardCounter.text = str(player_deck.size())
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/Cards/" + card_drawn_name + ".png")
	#var card_image_path = str("res://Assets/card_temporaire.png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	# Populer les propriétés de la carte
	new_card.mana = card_database_reference.CARDS[card_drawn_name][0]
	new_card.damage = card_database_reference.CARDS[card_drawn_name][1]
	new_card.armor = card_database_reference.CARDS[card_drawn_name][2]
	new_card.heal = card_database_reference.CARDS[card_drawn_name][3]
	new_card.card_effect = card_database_reference.CARDS[card_drawn_name][4]
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][5]
	new_card.card_name = card_database_reference.CARDS[card_drawn_name][6]
	
	new_card.get_node("Mana").text = str(new_card.mana)
	new_card.get_node("CardEffect").text = new_card.card_effect
	
	card_manager.add_child(new_card)
	new_card.name = "Card"
	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
func draw_all_cards():
	print("Draw all")
	print(player_deck)
	player_deck = player_deck_copy.duplicate()
	player_deck.shuffle()
	for i in range(HAND_SIZE):
		print(i)
		draw_card()
	#draw_card()
	#draw_card()
	
