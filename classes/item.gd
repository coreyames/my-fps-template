class_name Item 
extends Node3D

const default_id: int = -1
const default_item_name: String = '<unset>' 
var id: int = default_id
var item_name: String = default_item_name

func use(params) -> void:
	print('override me')
	return
