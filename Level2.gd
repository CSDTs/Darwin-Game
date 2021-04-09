extends Node2D

var plate = 0

func _ready():
#	$TakeDrop.visible = false
#	$plate.visible = false
	pass

func _process(delta):
#	if Input.is_action_just_pressed("drop"):
#		print('d pressed')
#	get_input()
#	if plate == 0:
#		$box1/plate.visible = true
##		$plate.visible = true
#	else:
#		$box1/plate.visible = false
	pass

#func get_input():
#	if Input.is_action_just_pressed("drop"):
#		print('d pressed')
#		$box1/TakeDrop.visible = false
#		$box2/TakeDrop.visible = false
#		$box3/TakeDrop.visible = false
#		$box1/plate.visible = false
#		$box2/medallion_man.visible = false
#		$box3/teapot.visible = false

func _on_box1_body_entered(body):
	if body.name == "Player":
		$box2/TakeDrop.visible = true
		$box1/plate.visible = true
#	if Input.is_key_pressed(KEY_T):
#		$TakeDrop.visible = false
#		$plate.visible = false
#		plate = 0
#		hide()
	#itemsl2.visible = true  # Replace with function body.

func _on_box2_body_entered(body):
	if body.name == "Player":
		$box2/TakeDrop.visible = true
		$box2/medallion_man.visible = true
#		hide()
	#itemsl2.visible = true 

func _on_box3_body_entered(body):
	if body.name == "Player":
		$box3/TakeDrop.visible = true
		$box3/teapot.visible = true
#		hide()

#back button to main menu screen
func _on_Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")
	#get_node("/root/Globals").load_new_scene(Main_Menu)

func _on_Josiah_body_entered(body):
	pass # Replace with function body.
