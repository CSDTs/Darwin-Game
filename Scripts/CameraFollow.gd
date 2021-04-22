extends Camera2D

onready var target = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/Lawyer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = target.position
