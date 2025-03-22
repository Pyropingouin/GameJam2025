extends Node2D

const HAND_SIZE = 4
const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.5

@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"

var player_deck = ["Attack1", "Attack2", "Armor1", "Attack1", "Heal1"]
var card_database_reference

func _ready() -> void:
	player_deck.shuffle()
	$CardCounter.text = str(player_deck.size())
	
	card_database_reference = preload("res://Scripts/card_database.gd")
	
	# Main de départ
	for i in range(HAND_SIZE):
		draw_card()

func draw_card():
	print("Draw card")
	
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	$CardCounter.text = str(player_deck.size())
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	#var card_image_path = str("res://Assets/" + card_drawn_name + ".png")
	var card_image_path = str("res://Assets/card_temporaire.png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	# Populer les propriétés de la carte
	new_card.damage = card_database_reference.CARDS[card_drawn_name][0]
	new_card.armor = card_database_reference.CARDS[card_drawn_name][1]
	new_card.heal = card_database_reference.CARDS[card_drawn_name][2]
	new_card.card_effect = card_database_reference.CARDS[card_drawn_name][3]
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][4]
	
	new_card.get_node("CardEffect").text = new_card.card_effect
	
	card_manager.add_child(new_card)
	new_card.name = "Card"
	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
