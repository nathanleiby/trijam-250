class_name Card

extends Node2D

signal card_clicked(value: int)

var card_value: int = 0:
	set(v):
		card_value = v
		$Control/BigLabel.text = str(v)
		$Control/TopRightLabel.text = str(v)
		$Control/BottomLeftLabel.text = str(v)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

