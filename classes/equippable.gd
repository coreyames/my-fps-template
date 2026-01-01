class_name Equippable
extends Node

enum Type {
	ABSTRACT,
	WEAPON,
	ARMOR
}

var type: Type = Type.ABSTRACT;
var id: int = -1;

func _ready() -> void:
	name = "Equippable";

func _init(_id: int) -> void:
	id = _id;
	return;
