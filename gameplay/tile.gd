class_name Tile

extends Node2D

@onready var label: Label = $Control/Label as Label
@onready var idxLabel: Label = $Control/IdxLabel as Label

var bonus_value: int = 0:
	set(v):
		bonus_value = v
		if v == 0:
			label.text = ""
		else:
			label.text = "+%d" % v

var idx_value: int = 0:
	set(v):
		idx_value = v
		idxLabel.text = "%d" % v
