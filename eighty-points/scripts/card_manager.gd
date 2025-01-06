extends Node2D
const COLLISION_MASK_CARD = 1
const DEFAULT_CARD_MOVE_SPEED = 0.1

var card_being_dragged
var screen_size
var is_hovering_on_card

var player_hand_reference
var to_play_reference
var ally_hand_reference 
var op_left_hand_reference
var op_right_hand_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"player hand"
	ally_hand_reference = $"ally hand"
	op_left_hand_reference = $"op left hand"
	op_right_hand_reference = $"op right hand"
	to_play_reference = $"to play"
	$"../input manager".connect("left_mouse_button_released", on_left_click_released)
	$"../input manager".connect("left_mouse_button_clicked", on_left_click_clicked)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_drag(card):
	if card in player_hand_reference.player_hand:
		card_being_dragged = card
		
func finish_drag ():
	card_being_dragged.scale =  Vector2(1, 1)
	#if card_being_dragged.get_position().y > 700:
		#player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
		#to_play_reference.remove_card_from_hand(card_being_dragged)
	#elif card_being_dragged.get_position().y < 700:
		#player_hand_reference.remove_card_from_hand(card_being_dragged)
		#to_play_reference.add_card_to_hand(card_being_dragged)
	card_being_dragged = null
	
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null
	
func all_raycast_results():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	var results = []
	for i in range(0, result.size()):
		results.append(result[i].collider.get_parent())
	return results


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
			
func connect_card_signals (card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_left_click_released():
	if card_being_dragged:
		finish_drag()

func on_left_click_clicked():
	var card = raycast_check_for_card()
	if card:
		card.scale =  Vector2(0.95, 0.95)
		#really weird selecting things is happening but oh well
		if card in player_hand_reference.to_play:
			player_hand_reference.deselect_card(card)
		elif card in player_hand_reference.player_hand:
			player_hand_reference.select_card(card)
	
func on_hovered_over_card(card):
	var card_hover = raycast_check_for_card()
	var all_cards_hovered = all_raycast_results()
	if all_cards_hovered.size() >= 2:
		for i in range(0, all_cards_hovered.size()):
			var current_card = all_cards_hovered[i]
			if current_card != card_hover and current_card.position.y != 960:
				highlight_card(current_card, false)
				highlight_card(card_hover, true)
	elif !is_hovering_on_card :
		if card in player_hand_reference.player_hand or card in player_hand_reference.to_play:
			is_hovering_on_card = true
			highlight_card (card, true)
	#if a new card is hovered over, need to remove hover on existing card
	#function will not be called unless new card hovered over
	
	
func on_hovered_off_card (card):
	if !card_being_dragged:
		if card in player_hand_reference.player_hand or card in player_hand_reference.to_play:
			highlight_card (card, false)
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered, true)
			else:
				is_hovering_on_card = false
	
func highlight_card(card, hovered):
	var row_y = 960
	if card in player_hand_reference.to_play:
		card.position = Vector2(card.get_position().x, row_y - 70)
		if hovered:
			card.scale =  Vector2(1.05, 1.05)
			card.position = Vector2(card.get_position().x, row_y - 90)
		else:
			card.position = Vector2(card.get_position().x, row_y- 70)
			card.scale =  Vector2(1, 1)
	elif card in player_hand_reference.player_hand:
		if hovered:
			card.scale =  Vector2(1.05, 1.05)
			card.position = Vector2(card.get_position().x, row_y - 20)
		else:
			card.position = Vector2(card.get_position().x, row_y)
			card.scale =  Vector2(1, 1)
			

	
		
	
