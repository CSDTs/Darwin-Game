extends StaticBody2D

onready var dialog = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var courtroom =  get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Courtroom")
onready var globals = get_node("/root/Globals")

# True after the artifact is declined with D, until D is released. Keeps movement
# disabled so the same keypress that declined doesn't also move the player right.
var awaiting_drop_release = false

# True while the player is inside this artifact's interaction area.
var player_near = false

func _ready():
	#When the item is ready, turn on the one way collision (so the player can walk through it)
	$CollisionShape2D.one_way_collision = true
	$Area2D.connect("body_entered", self, "_on_interaction_area_entered")
	$Area2D.connect("body_exited", self, "_on_interaction_area_exited")
	if self.name == "Bone":
		$CanvasLayer/Control/Bone.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Anatomy Specimen: a bone from Professor Monro's lecture collection.[/center]"
	elif self.name == "Rocks":
		$CanvasLayer/Control/Rocks.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Plinian Society Note: This note shows Darwin's early exposure to natural history discussion and evidence-based scientific debate. It is not direct evidence of Darwin's abolitionist views, but it helps show that his later ideas grew from observation, evidence, and scientific argument rather than racial ideology.[/center]"
	elif self.name == "Portrait":
		$CanvasLayer/Control/Portrait.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Abolitionist Keepsake: a portrait commissioned by John Edmonstone to mark his friendship with Darwin.[/center]"
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
	# Show "Press Space to interact" while the player is near and the artifact is
	# revealed. The prompt hides itself during dialogue / take-drop / Case File.
	$InteractionPrompt.set_showing(player_near and visible)

	#If the item's image and options appear only
	if getItemControlLayer() == true:
		
		#If the user drops/declines the item, hide the prompt. Movement stays
		#disabled until D is released so this same press doesn't move the player.
		if Input.is_action_just_pressed("drop"):
			setItemControlLayer(false)
			awaiting_drop_release = true

		#Else, controls the proper level's additional canvas elements (like courtrooms and dialogs)
		elif Input.is_action_just_pressed('pickup'):
			var scene = get_tree().get_current_scene()
			if scene.get_name() == "Level1":
				#Level 1: collect the artifact and stay until all three are gathered
				setItemControlLayer(false)
				scene.collect_artifact(self)
			else:
				courtroom.visible = true
				dialog.launch_conversation(self.name)
				setItemControlLayer(false)
	elif awaiting_drop_release:
		#Restore movement only once the drop key (D) has actually been released.
		if not Input.is_action_pressed("drop"):
			awaiting_drop_release = false
			globals.canMove = true

#Sets state of control layer. Opening the prompt enters "artifact decision mode"
#and disables player movement so movement keys (e.g. D) don't fire while choosing.
func setItemControlLayer(status):
	$CanvasLayer/Control.visible = status
	if status == true:
		globals.canMove = false
	
#Gets the state of the control layer
func getItemControlLayer():
	return $CanvasLayer/Control.visible

func _on_interaction_area_entered(body):
	if body.name == "Lawyer":
		player_near = true

func _on_interaction_area_exited(body):
	if body.name == "Lawyer":
		player_near = false
