extends Node2D

signal draw_phase_over

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2

var draw_turn

var card_deck = [
	"AceOfSpades", "2OfSpades", "3OfSpades", "4OfSpades", "5OfSpades", "6OfSpades", "7OfSpades", "8OfSpades", "9OfSpades", "10OfSpades", "JackOfSpades", "QueenOfSpades", "KingOfSpades",
	"AceOfHearts", "2OfHearts", "3OfHearts", "4OfHearts", "5OfHearts", "6OfHearts", "7OfHearts", "8OfHearts", "9OfHearts", "10OfHearts", "JackOfHearts", "QueenOfHearts", "KingOfHearts",
	"AceOfDiamonds", "2OfDiamonds", "3OfDiamonds", "4OfDiamonds", "5OfDiamonds", "6OfDiamonds", "7OfDiamonds", "8OfDiamonds", "9OfDiamonds", "10OfDiamonds", "JackOfDiamonds", "QueenOfDiamonds", "KingOfDiamonds",
	"AceOfClubs", "2OfClubs", "3OfClubs", "4OfClubs", "5OfClubs", "6OfClubs", "7OfClubs", "8OfClubs", "9OfClubs", "10OfClubs", "JackOfClubs", "QueenOfClubs", "KingOfClubs",
	"AceOfSpades", "2OfSpades", "3OfSpades", "4OfSpades", "5OfSpades", "6OfSpades", "7OfSpades", "8OfSpades", "9OfSpades", "10OfSpades", "JackOfSpades", "QueenOfSpades", "KingOfSpades",
	"AceOfHearts", "2OfHearts", "3OfHearts", "4OfHearts", "5OfHearts", "6OfHearts", "7OfHearts", "8OfHearts", "9OfHearts", "10OfHearts", "JackOfHearts", "QueenOfHearts", "KingOfHearts",
	"AceOfDiamonds", "2OfDiamonds", "3OfDiamonds", "4OfDiamonds", "5OfDiamonds", "6OfDiamonds", "7OfDiamonds", "8OfDiamonds", "9OfDiamonds", "10OfDiamonds", "JackOfDiamonds", "QueenOfDiamonds", "KingOfDiamonds",
	"AceOfClubs", "2OfClubs", "3OfClubs", "4OfClubs", "5OfClubs", "6OfClubs", "7OfClubs", "8OfClubs", "9OfClubs", "10OfClubs", "JackOfClubs", "QueenOfClubs", "KingOfClubs",
	"RedJoker", "RedJoker", "BlackJoker", "BlackJoker"
]

var card_database_reference
var turn_manager_reference
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	card_deck.shuffle()
	card_database_reference = preload("res://scripts/card_database.gd")
	timer = $"../draw timer"
	timer.one_shot = true
	timer.wait_time = 0.3
	turn_manager_reference = $"../turn manager"


func new_card():
	var card_drawn_name = card_deck[0]
	card_deck.erase(card_drawn_name)
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://assets/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.value = card_database_reference.CARDS[card_drawn_name][0]
	new_card.suit = card_database_reference.CARDS[card_drawn_name][1]
	$"../card manager".add_child(new_card)
	new_card.name = "Card"
	return new_card

func draw_card():
	 # 0 for player 
	for i in range(0, card_deck.size()):
		if card_deck.size() == 8:
			$Area2D/CollisionShape2D.disabled = true
			print("draw over")
			emit_signal("draw_phase_over")
			break
		$"../card manager/player hand".add_card_to_hand([new_card()], CARD_DRAW_SPEED)
		$Area2D/CollisionShape2D.disabled = true
		timer.start()
		await timer.timeout
		var op_right_new_card = new_card()
		if op_right_new_card.value == 3 and turn_manager_reference.no_cards_played(turn_manager_reference.trump_flip) and turn_manager_reference.first_round:
			turn_manager_reference.trump_flip[1].append(op_right_new_card)
			turn_manager_reference.trump_flip[1][0].rotation = PI/2
			turn_manager_reference.trump_flip[1][0].position = Vector2(1350,540)
		else:
			$"../card manager/op right hand".add_card_to_hand([op_right_new_card], CARD_DRAW_SPEED)
		timer.start()
		await timer.timeout
		var ally_hand_new_card = new_card()
		if ally_hand_new_card.value == 3 and turn_manager_reference.no_cards_played(turn_manager_reference.trump_flip) and turn_manager_reference.first_round:
			turn_manager_reference.trump_flip[2].append(ally_hand_new_card)
			turn_manager_reference.trump_flip[2][0].position = Vector2(960,335)
		else:
			$"../card manager/ally hand".add_card_to_hand([ally_hand_new_card], CARD_DRAW_SPEED)
		timer.start()
		await timer.timeout
		var op_left_new_card = new_card()
		if op_left_new_card.value == 3 and turn_manager_reference.no_cards_played(turn_manager_reference.trump_flip) and turn_manager_reference.first_round:
			turn_manager_reference.trump_flip[3].append(op_left_new_card)
			turn_manager_reference.trump_flip[3][0].rotation = 3*PI/2
			turn_manager_reference.trump_flip[3][0].position = Vector2(540,540)
		else:
			$"../card manager/op left hand".add_card_to_hand([op_left_new_card], CARD_DRAW_SPEED)
		timer.start()
		await timer.timeout

func bottom_cards():
	var bottom_cards = []
	for i in range(0, card_deck.size()):
		bottom_cards.append(new_card())
	return bottom_cards
		
