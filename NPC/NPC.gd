extends KinematicBody2D

onready var node = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var hint = $Area2D/Control
onready var item

func _ready():
	if self.name == "Monro":
		$Monro.visible = true
		item = get_node("/root/Level1/Bone")
		$CanvasLayer/Control/Monro.visible = true
		hint.get_node("RichTextLabel").bbcode_text = "[center]Anatomy Classroom\nProfessor Monro - press F to talk[/center]"
	elif self.name == 'Jameson':
		$Jameson.visible = true
		item = get_node("/root/Level1/Rocks")
		$CanvasLayer/Control/Jameson.visible = true
		hint.get_node("RichTextLabel").bbcode_text = "[center]Natural History Lecture Hall\nProfessor Jameson - press F to talk[/center]"
	elif self.name == "Edmonstone":
		$Edmonstone.visible = true
		item = get_node("/root/Level1/Portrait")
		$CanvasLayer/Control/Edmonstone.visible = true
		hint.get_node("RichTextLabel").bbcode_text = "[center]Specimen Room\nProfessor Edmonstone - press F to talk[/center]"
	elif self.name == "Uncle":
		$Uncle.visible = true
		item = [get_node("/root/Level2/Teapot"), get_node("/root/Level2/Plate"), get_node("/root/Level2/Medallion")]
		$CanvasLayer/Control/Uncle.visible = true
	elif self.name == "Captain":
		$Captain.visible = true
		item = [get_node("/root/Level3/Page1"), get_node("/root/Level3/Page2"), get_node("/root/Level3/Page3")]
		$CanvasLayer/Control/Captain.visible = true

	# Give the small interaction prompt this professor's role/name (two-line).
	var role = ""
	if self.name == "Monro":
		role = "Anatomy Professor - Monro"
	elif self.name == "Jameson":
		role = "Natural History Professor - Jameson"
	elif self.name == "Edmonstone":
		role = "Taxidermy Teacher - Edmonstone"
	var prompt = get_node_or_null("InteractionPrompt")
	if prompt != null:
		prompt.set_prompt(role, "Press Space to talk")

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
