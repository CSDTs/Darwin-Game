extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.

#	pass
