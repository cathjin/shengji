extends Node

const CARD_WIDTH = 200

var turn = 0
var in_play = [[],[],[],[]] 
var trump_flip = [[],[],[],[]] 

var ally_round = 3
var op_round = 3
var first_round
var trump
var zhuang_jia
var starter = 0

var card_database_reference 
var player_hand_reference
var ally_hand_reference
var op_left_hand_reference
var op_right_hand_reference 
var deck_reference 
var timer

var in_draw_phase
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database_reference = preload("res://scripts/card_database.gd")
	player_hand_reference = $"../card manager/player hand"
	ally_hand_reference = $"../card manager/ally hand"
	op_left_hand_reference = $"../card manager/op left hand"
	op_right_hand_reference = $"../card manager/op right hand"
	deck_reference = $"../deck"
	timer = $"../round timer"
	timer.one_shot = true
	timer.wait_time = 1.0
	in_draw_phase = true
	first_round = true
	in_play = [[],[],[],[]] 
	trump_flip = [[],[],[],[]] 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_play_cards_button_pressed() -> void:
	if in_draw_phase:
		$"../play cards button".disabled = true
		$"../play cards button".visible = false
		if player_hand_reference.to_play.size() == 1 and player_hand_reference.to_play[0].value == ally_round:
			trump = player_hand_reference.to_play[0].suit
			trump_flip[0].append(player_hand_reference.to_play[0])
			player_hand_reference.remove_card_from_hand(player_hand_reference.to_play[0])
			player_hand_reference.to_play = []
			trump_flip[0][0].position = Vector2(960,745)
		else:
			for i in range(0, player_hand_reference.to_play.size()):
				player_hand_reference.deselect_card(player_hand_reference.to_play[i])
			print("badbad")
			$"../play cards button".disabled = false
			$"../play cards button".visible = true
	elif check_cards_to_play(player_hand_reference.to_play):
		$"../play cards button".disabled = true
		$"../play cards button".visible = false
		in_play[0] = (player_hand_reference.to_play)
		var hand = player_hand_reference.player_hand
		for i in range (0, player_hand_reference.to_play.size()):
			player_hand_reference.remove_card_from_hand(player_hand_reference.to_play[i])
		player_hand_reference.to_play = []
		update_in_play_position_allies(in_play[0], 960, 745)
		play_round(1)
	else:
		print("badbadbad")

func check_cards_to_play(to_play):
	var to_play_first_card = to_play[0]
	#need to change in case they run out
	if to_play.size() == 0:
		print("bad")
		return false
	elif to_play.size() == 1:
		if no_cards_played(in_play):
			return true
		else:
			return true
	else:
		print("hahaha")
		return false
	return "boo"
func play_round(turn):
	var cards
	if all_cards_played():
		timer.start()
		await timer.timeout
		round_winner()
		return
	if ally_hand_reference.player_hand.size() == 0 and  op_left_hand_reference.player_hand.size() == 0 and op_right_hand_reference.player_hand.size() == 0 and player_hand_reference.player_hand.size()==0:
		return
	if turn == 0: 
		print("player going")
		player_turn()
		return
	elif turn == 1:
		print("right op going")
		cards = pick_card(op_right_hand_reference.player_hand)
		in_play[1] = cards
		timer.start()
		await timer.timeout
		for i in range(0, cards.size()):
			op_right_hand_reference.remove_card_from_hand(cards[i])
		print(in_play)
		update_in_play_position_ops(in_play[1], 540, 1320)
		turn += 1
		play_round(turn)
		return
	elif turn == 2: 
		print("ally going")
		cards = pick_card(ally_hand_reference.player_hand)
		in_play[2] = cards
		timer.start()
		await timer.timeout
		for i in range(0, cards.size()):
			ally_hand_reference.remove_card_from_hand(cards[i])
		print(in_play)
		update_in_play_position_allies(in_play[2], 960, 335)
		turn += 1
		play_round(turn)
		return
	else:
		print ("left op going")
		cards = pick_card(op_left_hand_reference.player_hand)
		in_play[3] = cards
		timer.start()
		await timer.timeout
		for i in range(0, cards.size()):
			op_left_hand_reference.remove_card_from_hand(cards[i])
		print(in_play)
		update_in_play_position_ops(in_play[3], 540, 600)
		turn = 0
		play_round(turn)
		return
		
func player_turn():
	$"../play cards button".disabled = false
	$"../play cards button".visible = true

func pick_card(hand):
	var to_play = []
	var needed_length = in_play[starter].size()
	print(no_cards_played(in_play))
	print(in_play)
	if no_cards_played(in_play):
		to_play.append(hand[0])
		return to_play
	else:
		for i in range(0, hand.size()):
			if hand[i].suit == in_play[starter][0].suit:
				to_play.append(hand[i])
			if needed_length == to_play.size():
				return to_play
		for i in range(to_play.size(), needed_length):
			to_play.append(hand[i])
	return to_play


func _on_deck_draw_phase_over() -> void:
	in_draw_phase = false
	if trump_flip[0].size() >= 1:
		for i in range (0, trump_flip[0].size()):
			player_hand_reference.add_card_to_hand([trump_flip[0][i]], 0.5)
	if trump_flip[1].size() >= 1:
		for i in range (0, trump_flip[1].size()):
			op_right_hand_reference.add_card_to_hand([trump_flip[1][i]], 0.5)
	if trump_flip[2].size() >= 1:
		for i in range (0, trump_flip[2].size()):
			ally_hand_reference.add_card_to_hand([trump_flip[2][i]], 0.5)
	if trump_flip[3].size() >= 1:
		for i in range (0, trump_flip[3].size()):
			op_left_hand_reference.add_card_to_hand([trump_flip[3][i]], 0.5)
	starter = trump_flip_winner()
	play_round(starter)
	trump = trump_flip[trump_flip_winner()][0].suit
	trump_flip = [[],[],[],[]]
	if starter == 0:
		player_hand_reference.add_card_to_hand(deck_reference.bottom_cards(), 0.2)
	elif starter == 1:
		print("yes")
		op_right_hand_reference.add_card_to_hand(deck_reference.bottom_cards(), 0.2)
	elif starter == 2:
		ally_hand_reference.add_card_to_hand(deck_reference.bottom_cards(), 0.2)
		print("yes")
	else:
		op_left_hand_reference.add_card_to_hand(deck_reference.bottom_cards(), 0.2)
		print("yoho")
func trump_flip_winner():
	if trump_flip[0].size() > trump_flip[1].size() and trump_flip[0].size() > trump_flip[2].size() and trump_flip[0].size() > trump_flip[3].size():
		return 0
	elif trump_flip[1].size() > trump_flip[0].size() and trump_flip[1].size() > trump_flip[2].size() and trump_flip[1].size() > trump_flip[3].size():
		return 1
	elif trump_flip[2].size() > trump_flip[0].size() and trump_flip[2].size() > trump_flip[1].size() and trump_flip[2].size() > trump_flip[3].size():
		return 2
	else:
		return 3
func update_in_play_position_allies(player_in_play, center, y_pos):
	for i in range(0, player_in_play.size()):
		var card = player_in_play[i]
		var new_position = Vector2(calculate_card_position(i, player_in_play, center), y_pos)
		card.hand_position = new_position
		animate_card_to_position(card, new_position, 0.2)
func update_in_play_position_ops(player_in_play, center, x_pos):
	for i in range(0, player_in_play.size()):
		var card = player_in_play[i]
		print (player_in_play)
		print(card)
		var new_position = Vector2(x_pos, calculate_card_position(i, player_in_play, center))
		card.hand_position = new_position
		animate_card_to_position(card, new_position, 0.2)
func calculate_card_position(index, hand, center):
	var total_width = (hand.size() - 1) * CARD_WIDTH
	var offset = center + index * CARD_WIDTH - total_width / 2
	return offset
	
func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func round_winner():
	var best_hand = in_play[0]
	var best_player_index = 0
	for i in range(0, in_play.size()):
		for j in range (0, in_play[i].size()):
			in_play[i][j].visible =  false
	for i in range(1, 4):
		if compare_hands(in_play[i], best_hand, in_play[starter][0].suit):
			best_hand = in_play[i]
			best_player_index = i
	in_play = [[],[],[],[]]
	starter = best_player_index
	print (best_player_index)
	play_round(best_player_index)

func compare_hands(hand1, hand2, round_suit):
	for i in range(0, hand1.size()):
		if hand1[i].suit == round_suit and hand2[i].suit == round_suit:
			if hand1[i].value >= hand2[i].value:
				print("a")
				return true
			else:
				print("b")
				return false
		elif hand1[0].suit == 0:
			print("c")
			return true
		else:
			return false

func no_cards_played(array):
	return array[0].size() == 0 and array[1].size() == 0 and array[2].size() == 0 and array[3].size() == 0
func all_cards_played():
	return in_play[0].size() != 0 and in_play[1].size() != 0 and in_play[2].size() != 0 and in_play[3].size() != 0
