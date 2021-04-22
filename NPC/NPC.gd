extends KinematicBody2D

onready var node = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var hint = $Area2D/Control
onready var item

func _ready():
	if self.name == "Monro":
		$Monro.visible = true
		item = get_node("/root/Level1/Bone")
		$CanvasLayer/Control/Monro.visible = true
	elif self.name == 'Jameson':
		$Jameson.visible = true
		item = get_node("/root/Level1/Rocks")
		$CanvasLayer/Control/Jameson.visible = true
	elif self.name == "Edmonstone":
		$Edmonstone.visible = true
		item = get_node("/root/Level1/Portrait")
		$CanvasLayer/Control/Edmonstone.visible = true
	elif self.name == "Uncle":
		$Uncle.visible = true
		item = [get_node("/root/Level2/Teapot"), get_node("/root/Level2/Plate"), get_node("/root/Level2/Medallion")]
		$CanvasLayer/Control/Uncle.visible = true
	elif self.name == "Captain":
		$Captain.visible = true
		item = [get_node("/root/Level3/Page1"), get_node("/root/Level3/Page2"), get_node("/root/Level3/Page3")]
		$CanvasLayer/Control/Captain.visible = true

func start_conversation():
	if self.name == "Uncle" || self.name == "Captain":
		if(item[0] != null && item[1] != null && item[2] != null):
			if (item[0].visible != true || item[1].visible != true || item[2].visible != true):	
				node.launch_popup()
				hint.visible = false
				$CanvasLayer/Control.visible = true
		else:
			node.launch_popup()
			$CanvasLayer/Control.visible = true
	else:
		if(item != null):
			if (item.visible != true):	
				node.launch_popup()
				hint.visible = false
				$CanvasLayer/Control.visible = true
		else:
			node.launch_popup()
			$CanvasLayer/Control.visible = true
