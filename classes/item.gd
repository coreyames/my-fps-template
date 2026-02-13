class_name Item 
extends Node3D

var id: int = -1

func _ready() -> void:
	name = "Item"

func _init(_id: int) -> void:
	id = _id
	return
