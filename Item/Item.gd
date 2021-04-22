extends StaticBody2D

onready var dialog = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var courtroom =  get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Courtroom")

func _ready():
	#When the item is ready, turn on the one way collision (so the player can walk through it)
	$CollisionShape2D.one_way_collision = true
	if self.name == "Bone":
		$CanvasLayer/Control/Bone.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It appears to be a bone.[/center]"
	elif self.name == "Rocks":
		$CanvasLayer/Control/Rocks.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It is a pile of rocks.[/center]"
	elif self.name == "Portrait":
		$CanvasLayer/Control/Portrait.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It is the portrait.[/center]"
	elif self.name == "Plate":
		$CanvasLayer/Control/Plate.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It appears to be a plate.[/center]"
	elif self.name == "Teapot":
		$CanvasLayer/Control/Teapot.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It is a teapot..[/center]"
	elif self.name == "Medallion":
		$CanvasLayer/Control/Medallion.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]This is the medallion.[/center]"
	elif self.name == "Page1":
		$CanvasLayer/Control/Page1.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]I deduce from extreme difficulty of hypothesis of connecting mollusca and vertebrata, that there must be very great gaps.[/center]"
	elif self.name == "Page2":
		$CanvasLayer/Control/Page2.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Tapirs existing in East Indian seas. Marsupial animals all show greater connection in quadrupeds, but plants do not follow by any means.[/center]"
	elif self.name == "Page3":
		$CanvasLayer/Control/Page3.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Here is a journal entry about a Black teacher who was the intellectual equal to his white colleagues. That must be John Edmonstone. And next to i another quote: \"Animals whom we have made our slaves, we do not like to consider our equals. Do not slaveholders wish to make the black man other kind?\"[/center]"
	
func _process(delta):
	#If the item's image and options appear only
	if getItemControlLayer() == true:
		
		#If the user drops the item, it just hides that canvas
		if Input.is_action_just_pressed("drop"):
			setItemControlLayer(false)
			
		#Else, controls the proper level's additional canvas elements (like courtrooms and dialogs)
		elif Input.is_action_just_pressed('pickup'):
			courtroom.visible = true
			dialog.launch_conversation(self.name)
			setItemControlLayer(false)

#Sets state of control layer	
func setItemControlLayer(status):
	$CanvasLayer/Control.visible = status
	
#Gets the state of the control layer
func getItemControlLayer():
	return $CanvasLayer/Control.visible
