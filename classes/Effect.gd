class_name Effect extends Node

# possible effect types
enum Type {
	DAMAGE,
	STUN
}

var type: Type

# damage effect vars
var min_dmg: int
var max_dmg: int

# stun
var duration: int
