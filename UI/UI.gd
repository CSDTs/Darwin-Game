extends CanvasLayer

onready var node = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var label = $NextLevel/Header.bbcode_text
onready var nextScene
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_current_scene().get_name() == "Level1":
		$NextLevel/Header.bbcode_text = "Now Onto the Second Level"	
		nextScene = "res://Level2.tscn"
		$NextLevel/Level1.visible = true
	elif get_tree().get_current_scene().get_name() == "Level2":
		$NextLevel/Header.bbcode_text = "Now Onto the Third Level"	
		nextScene = "res://Level3.tscn"
		$NextLevel/Level2.visible = true
	elif get_tree().get_current_scene().get_name() == "Level3":
		$NextLevel/Header.bbcode_text = "Head Back to the Main Menu"	
		nextScene = "res://Main Menu/Main_Menu.tscn"
		$NextLevel/Level3.visible = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $NextLevel.visible == true:
		if Input.is_action_just_pressed("interact"):
			get_tree().change_scene(nextScene)
