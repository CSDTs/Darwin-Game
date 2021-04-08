extends Camera2D


onready var target = get_node('/root/Level3/Lawyer')
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = target.position
