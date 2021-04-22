extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var itemsl1 = $Items_Level1
onready var itemsl2 = $Items_Level2


# Called when the node enters the scene tree for the first time.
#func _ready():





func _on_glow_body_entered(body):
	if body.name == "Player":
		hide()
		itemsl1.visible = true # Replace with function body.
	
func _on_box2_body_entered(body):
	if body.name == "Player":
		hide()
	#itemsl2.visible = true 


func _on_box1_body_entered(body):
	if body.name == "Player":
		hide()
	#itemsl2.visible = true  # Replace with function body.


