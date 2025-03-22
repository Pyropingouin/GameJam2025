extends Node

const CARD_MOVE_SPEED = 0.3

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var deck: Node2D = $"../Deck"
@onready var discard_pile_reference: Node2D = $"../DiscardPile"

var discard_pile = []
var card_being_played

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play_a_card(card):
	#print("Play a card")
	#print(card)
	card_being_played = card
	# Ajouter la carte dans la DiscardPile
	discard_pile.append(card)
	# Enlever la carte du player_hand
	player_hand.remove_card_from_hand(card)
	# Enlever la carte du deck
	deck.player_deck.erase(card)
	# Déplacer la carte dans la DiscardPile
	var new_pos = discard_pile_reference.position
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)
	tween.connect("finished", on_tween_finished)
	
	# Faire l'effet
	

func on_tween_finished():
	discard_pile_reference.get_node("CardCounter").text = str(discard_pile.size())
	# Détruire la carte
	card_being_played.queue_free()
