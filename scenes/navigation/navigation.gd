extends Node2D

const LAYERS := 10
const MAX_WIDTH := 5

const H_SPACING := 50
const W_SPACING := 50


var button_type := preload("res://scenes/navigation/location_node.tscn")

func _ready() -> void:
	var width
	var last_nodes := []
	var current_nodes := []
	
	for i in LAYERS:
		width = randi_range(3, MAX_WIDTH)
		for j in width:
			var loc_button := button_type.instantiate()
			loc_button.position = Vector2(480 - ((W_SPACING / 2) * (width - 1)) + (W_SPACING * (j - 1)), 50 + (H_SPACING * i))
			add_child(loc_button)
			current_nodes.append(loc_button)
			for k in last_nodes:
				k.next_nodes.append(loc_button)
		last_nodes = current_nodes
