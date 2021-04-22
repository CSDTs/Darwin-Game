extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var back = get_node("/root/Level1/CanvasLayer/Control/Button")
	back.connect("pressed", self, "_Button_pressed")

#back button to main menu screen
func _Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

