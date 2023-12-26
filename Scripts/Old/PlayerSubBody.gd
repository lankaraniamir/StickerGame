extends "res://Scripts/PlayerMainBody.gd"

#@onready var main_body = get_node("../../MainBody")

func _ready():
	pass

func _physics_process(delta):
	#constrict_bounds()
	shoot_if_input(delta)

