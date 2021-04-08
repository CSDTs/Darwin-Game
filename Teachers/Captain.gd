extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#onready var dialog = get_node("/root/Level1/Control")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


	
func start_conversation():
	var node = get_node("/root/Level3/CanvasLayer/Control/Popup")
	node.launch_popup()
	$CanvasLayer/Control.visible = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


