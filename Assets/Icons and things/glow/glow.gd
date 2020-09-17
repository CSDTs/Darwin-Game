extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var items



# Called when the node enters the scene tree for the first time.
func _ready():
	items = $Items # Replace with function body.



func _on_Player_hit():
	hide()
	items.visible = true # Replace with function body.
