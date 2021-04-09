extends Area2D

onready var itemsl1 = $Items_Level1
onready var itemsl2 = $Items_Level2
var plate = 0

func _ready():
#	$TakeDrop.visible = false
#	$plate.visible = false
	pass
	
#func _process(delta):
#	if plate == 0:
#		$"plate".visible = true
##		$plate.visible = true
#	else:
#		$"plate".visible = false
#	pass

#func _input(ev):
#	if Input.is_key_pressed(KEY_D):
#		$TakeDrop.visible = false
#		$plate.visible = false

func _on_box1_body_entered(body):
	if body.name == "Player":
		$TakeDrop.visible = true
		$plate.visible = true
#	if Input.is_key_pressed(KEY_T):
#		$TakeDrop.visible = false
#		$plate.visible = false
#		plate = 0
#		hide()
	#itemsl2.visible = true  # Replace with function body.

func _on_box2_body_entered(body):
	if body.name == "Player":
		$TakeDrop.visible = true
		$medallion_man.visible = true
#		hide()
	#itemsl2.visible = true 

func _on_box3_body_entered(body):
	if body.name == "Player":
		$TakeDrop.visible = true
		$teapot.visible = true
#		hide()
