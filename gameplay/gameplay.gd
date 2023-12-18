extends Node2D

# scenes we will dynamically instantiate
@export var tileScene: PackedScene
@export var cardScene: PackedScene

# reusable references
@onready var tiles: Node2D = $Board/Tiles
@onready var playerMatDeck: Node2D = $PlayerMat/Deck
@onready var playerMatHand: Node2D = $PlayerMat/Hand
@onready var playerMatDiscard: Node2D = $PlayerMat/Discard

func _process(_delta: float) -> void:
	return

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		call_deferred("_pause")

func _pause() -> void:
	$Paused.pause()
	get_tree().paused = true

const TILE_SIZE = 64
const HAND_SIZE = 2

func _ready():
	# generate board
	var board = generate_board()
	for i in range(board.size()):
		var tile = tileScene.instantiate()
		tile.position = Vector2(i * TILE_SIZE, 0)
		tiles.add_child(tile)
		tile.bonus_value = board[i]
		tile.idx_value = i + 1

	# generate player setup (deck, hand, ..)
	var player_deck = generate_deck()
	for i in range(HAND_SIZE):
		var next_card_value = player_deck.pop_back()
		var card: Card = cardScene.instantiate()
		# TODO: consider creating a PlayerMat or PlayerHand abstraction
		card.card_value = next_card_value
		card.position = Vector2(i * 128, 0)
		playerMatHand.add_child(card)

	# add cards to deck
	# add cards to discard, later (maybe show a dotted line to start)

	player_position = -1


const DECK_SIZE = 4

func generate_board():
	var total_steps: int = 0
	for i in range(1, DECK_SIZE + 1):
		total_steps += i

	var board = Array()
	board.resize(total_steps)
	board.fill(0)

	for i in range(1, DECK_SIZE + 1):
		# assign the "bonus tiles" to random position in board, but
		# - avoid collisions
		# - avoid placement last position
		var pos = randi() % total_steps
		while board[pos] != 0 or (pos == total_steps - 1):
			pos = randi() % total_steps
		board[pos] = i

	return board

func generate_deck() -> Array:
	# shuffle items from 1 to DECK_SIZE
	var player_deck: Array = range(1, DECK_SIZE + 1)
	player_deck.shuffle()
	return player_deck

var player_position = 0:
	set(value):
		player_position = value
		$Board/PlayerToken.position.x = value * TILE_SIZE

func move_player(steps: int) -> void:
	player_position += steps

