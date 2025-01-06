extends Node2D

const CARD_WIDTH = 30
const HAND_Y_POSITION = 960
const DEFAULT_CARD_MOVE_SPEED = 0.1

var player_hand = []
var player_hand_card_names = []
var to_play = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x/2
	

func add_card_to_hand(cards, speed):
	for i in range(0, cards.size()):
		if cards[i] not in player_hand:
			player_hand.insert(sort_cards(cards[i], player_hand), cards[i])
			update_hand_positions(speed)
		else:
			animate_card_to_position(cards[i], cards[i].hand_position, speed)
	
func update_hand_positions(speed):
	var card_y_position
	for i in range(player_hand.size()):
		var card = player_hand[i]
		if card in to_play:
			card_y_position = HAND_Y_POSITION - 70
		else:
			card_y_position = HAND_Y_POSITION
		var new_position = Vector2(calculate_card_position(i), card_y_position)
		card.z_index = i
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	
func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
		
func select_card(card):
	to_play.insert(sort_cards(card, to_play), card)
	update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
	
func deselect_card (card):
	to_play.erase(card)
	update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
#need to fix z index

func sort_cards(card, hand):
	for i in range(0, hand.size()):
		if card.value >= hand[i].value and card.suit < hand[i].suit:
			return i
		elif card.suit < hand[i].suit:
			return i
		elif card.value >= hand[i].value and card.suit == hand[i].suit:
			return i
	return hand.size()
