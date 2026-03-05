class_name Skill extends Node

const default_id: int = -1
const default_skill_name: String = '<unset>' 
var id: int = default_id
var skill_name: String = default_skill_name
var cost: int
var description: String

func use(params) -> void:
	print("override me")
	return
