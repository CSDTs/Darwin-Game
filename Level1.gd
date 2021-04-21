extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var nxtLvl = get_node("/root/Level1/CanvasLayer/NextLevel/NextLevelBtn")
	var back = get_node("/root/Level1/CanvasLayer/Control/Button")
	nxtLvl.connect("pressed", self, "_nextLevel_pressed")
	back.connect("pressed", self, "_Button_pressed")

func _process(delta):
	var next = get_node("/root/Level1/CanvasLayer/NextLevel")
	if next.visible == true && Input.is_action_just_pressed("interact"):
		_nextLevel_pressed()
		
func _nextLevel_pressed():
	get_tree().change_scene("res://Level2.tscn")

#back button to main menu screen
func _Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

