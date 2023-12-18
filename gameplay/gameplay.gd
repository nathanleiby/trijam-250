extends Node2D

# scenes we will dynamically instantiate
@export var tileScene: PackedScene
@export var cardScene: PackedScene

# reusable node references
@onready var tiles: Node2D = $Board/Tiles
@onready var playerMatDeck: Node2D = $PlayerMat/Deck
@onready var playerMatHand: Node2D = $PlayerMat/Hand
@onready var playerMatHandCards: Node2D = $PlayerMat/Hand/Cards
@onready var playerMatDiscard: Node2D = $PlayerMat/Discard
@onready var playerMatHandSelectIndicator: Sprite2D = $PlayerMat/Hand/SelectIndicator

# configuration
const TILE_SIZE = 64
const HAND_SIZE = 2
const DECK_SIZE = 4

# game state
var board: Array = []
var deck: Array = []
var hand: Array = []

func get_hand_size() -> int:
	return playerMatHandCards.get_child_count()

var select_indicator_idx = 0:
	set(v):
		select_indicator_idx = v
		playerMatHandSelectIndicator.position.x = v * 128 + 64

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		select_indicator_idx = clamp(select_indicator_idx - 1, 0, get_hand_size() - 1)
	if Input.is_action_just_pressed("move_right"):
		select_indicator_idx = clamp(select_indicator_idx + 1, 0, get_hand_size() - 1)
	if Input.is_action_just_pressed("accept"):
		var card_value = discard_card(select_indicator_idx)
		player_position += card_value
		draw_card()


func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		call_deferred("_pause")

func _pause() -> void:
	$Paused.pause()
	get_tree().paused = true


func _ready():
	# generate _board
	board = generate_board()
	for i in range(board.size()):
		var tile = tileScene.instantiate()
		tile.position = Vector2(i * TILE_SIZE, 0)
		tiles.add_child(tile)
		tile.bonus_value = board[i]
		tile.idx_value = i + 1

	# generate player setup (deck, hand, ..)
	generate_deck()
	for i in range(HAND_SIZE):
		draw_card()

	# add cards to deck
	# add cards to discard, later (maybe show a dotted line to start)

	player_position = -1


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

	# relayout all cards in hand
	var i = 0
	for c in playerMatHandCards.get_children():
		c.position = Vector2(i * 128, 0)
		i += 1

# returns the card_value of the discarded card
func discard_card(idx: int) -> int:
	# game state
	# var cardNodes: Array[Node] = playerMatHandCards.get_children()
	var cardsChildren = playerMatHandCards.get_children()
	if cardsChildren.size() == 0:
		return 0

	var card = cardsChildren[idx]
	var value = card.card_value
	playerMatHandCards.remove_child(card)
	card.queue_free()


	# keep count of discarded cards
	# playerMatDiscard.add_child(card)

	return value

func generate_board():
	var total_steps: int = 0
	for i in range(1, DECK_SIZE + 1):
		total_steps += i

	var _board = Array()
	_board.resize(total_steps)
	_board.fill(0)

	for i in range(1, DECK_SIZE + 1):
		# assign the "bonus tiles" to random position in _board, but
		# - avoid collisions
		# - avoid placement last position
		var pos = randi() % total_steps
		while _board[pos] != 0 or (pos == total_steps - 1):
			pos = randi() % total_steps
		_board[pos] = i

	return _board


var player_position = 0:
	set(value):
		player_position = value
		$Board/PlayerToken.position.x = value * TILE_SIZE
