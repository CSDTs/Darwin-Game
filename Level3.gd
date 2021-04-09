extends Node2D

#export (String, FILE) var Main_Menu
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#back button to main menu screen
func _on_Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")
	#get_node("/root/Globals").load_new_scene(Main_Menu)




func _on_RigidBody2D_body_shape_entered(body_id, body, body_shape, local_shape):
	print('hit') # Replace with function body.


func _on_Area2D_body_entered(body):
	print('hit') # Replace with function body.
