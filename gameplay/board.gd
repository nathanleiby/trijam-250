class_name Board

extends Node2D

# scenes we will dynamically instantiate
@export var tileScene: PackedScene

# reusable node references
@onready var tiles: Node2D = $Tiles
@onready var playerToken: Node2D = $PlayerToken
# configuration
const DECK_SIZE = Global.DECK_SIZE
const TILE_SIZE = 64

var player_position = 0:
	set(value):
		player_position = value
		playerToken.position.x = value * TILE_SIZE



func generate_board():
	# phase (1): generate the underlying data for the board
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

	# phase (2): generate the Node representation of the board

	# purge existing tiles in game board
	for c in tiles.get_children():
		tiles.remove_child(c)
		c.queue_free()

	for i in range(_board.size()):
		var tile = tileScene.instantiate()
		tile.position = Vector2(i * TILE_SIZE, 0)
		tiles.add_child(tile)
		tile.bonus_value = _board[i]
		tile.idx_value = i + 1

