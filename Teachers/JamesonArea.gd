extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if(body.name == 'Lawyer'):
		print("Interact with the teacher for more information...")
		var node = get_node("/root/Level1/CanvasLayer/Control/Popup")
		node.init_conversation('Jameson')
	pass # Replace with function body.


	
	
