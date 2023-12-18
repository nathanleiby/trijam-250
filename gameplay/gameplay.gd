extends Node2D

# scenes we will dynamically instantiate
@export var cardScene: PackedScene

# reusable node references
@onready var board: Board = $Board as Board
@onready var playerMatDeck: Node2D = $PlayerMat/Deck
@onready var playerMatHand: Node2D = $PlayerMat/Hand
@onready var playerMatHandCards: Node2D = $PlayerMat/Hand/Cards
@onready var playerMatDiscard: Node2D = $PlayerMat/Discard
@onready var playerMatHandSelectIndicator: Sprite2D = $PlayerMat/Hand/SelectIndicator

# configuration
const HAND_SIZE = 2
const DECK_SIZE = 4

# game state
var deck: Array = []

func get_hand_size() -> int:
	return playerMatHandCards.get_child_count()

var select_indicator_idx = 0:
	set(v):
		select_indicator_idx = v
		playerMatHandSelectIndicator.position.x = v * 128 + 64

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		select_indicator_idx = clamp(select_indicator_idx - 1, 0, max(get_hand_size() - 1, 0))
	if Input.is_action_just_pressed("move_right"):
		select_indicator_idx = clamp(select_indicator_idx + 1, 0, max(get_hand_size() - 1, 0))
	if Input.is_action_just_pressed("accept"):
		var card_value = play_card(select_indicator_idx)
		board.player_position += card_value
		draw_card()


func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		call_deferred("_pause")

func _pause() -> void:
	$Paused.pause()
	get_tree().paused = true


func next_puzzle():
	board.generate_board()
	generate_deck()
	generate_hand()
	board.player_position = -1

func _ready():
	next_puzzle()



func generate_deck():
	# shuffle items from 1 to DECK_SIZE
	deck = range(1, DECK_SIZE + 1)
	deck.shuffle()

# TODO: consider creating a PlayerMat or PlayerHand abstraction
func draw_card():
	# game state
	var next_card_value = deck.pop_back()
	if next_card_value == null:
		return

	var card: Card = cardScene.instantiate()
	card.card_value = next_card_value
	playerMatHandCards.add_child(card)

	_ui_relayout_cards_in_hand()

func _ui_relayout_cards_in_hand():
	var i = 0
	for c in playerMatHandCards.get_children():
		c.position = Vector2(i * 128, 0)
		i += 1

# returns the card_value of the discarded card
func play_card(idx: int) -> int:
	select_indicator_idx = 0

	var cardsChildren = playerMatHandCards.get_children()
	if cardsChildren.size() == 0:
		return 0

	var card = cardsChildren[idx]
	var value = card.card_value
	playerMatHandCards.remove_child(card)
	card.queue_free()

	_ui_relayout_cards_in_hand()

	# keep count of discarded cards
	# playerMatDiscard.add_child(card)

	return value

func generate_hand():
	# remove existing cards
	for c in playerMatHandCards.get_children():
		playerMatHandCards.remove_child(c)
		c.queue_free()

	for i in range(HAND_SIZE):
		draw_card()

func _on_next_puzzle_button_pressed() -> void:
	next_puzzle()
	$NextPuzzleButton.release_focus()
