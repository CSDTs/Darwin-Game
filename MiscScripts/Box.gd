extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.one_way_collision = true
	
func _process(delta):
	if $CanvasLayer/Control.visible == true:
		if Input.is_action_just_pressed("drop"):
			print('Item Dropped')
			$CanvasLayer/Control.visible = false
		elif Input.is_action_just_pressed('pickup'):
			if self.name =="Bone":
				var failDialog = get_node("/root/Level1/CanvasLayer/Control/Popup")
				failDialog.init_conversation("FailBone")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level1/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Rocks":
				var failDialog = get_node("/root/Level1/CanvasLayer/Control/Popup")
				failDialog.init_conversation("FailRocks")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level1/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Portrait":
				var failDialog = get_node("/root/Level1/CanvasLayer/Control/Popup")
				failDialog.init_conversation("SuccessPortrait")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level1/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Plate":
				var failDialog = get_node("/root/Level2/CanvasLayer/Control/Popup")
				failDialog.init_conversation("FailPlate")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level2/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Teapot":
				var failDialog = get_node("/root/Level2/CanvasLayer/Control/Popup")
				failDialog.init_conversation("FailTeapot")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level2/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Medallion":
				var failDialog = get_node("/root/Level2/CanvasLayer/Control/Popup")
				failDialog.init_conversation("SuccessMedallion")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level2/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Page1":
				var failDialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
				failDialog.init_conversation("Page1")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level3/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Page2":
				var failDialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
				failDialog.init_conversation("Page2")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level3/CanvasLayer/Courtroom")
				courtroom.visible = true
			elif self.name =="Page3":
				var failDialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
				failDialog.init_conversation("Page3")
				failDialog.launch_popup()
				failDialog.load_dialog()
				var courtroom = get_node("/root/Level3/CanvasLayer/Courtroom")
				courtroom.visible = true
			$CanvasLayer/Control.visible = false

func boneBox():
	print('It is a bone...')
	$CanvasLayer/Control.visible = true
	
func rockBox():
	print('It is a rock...')
	$CanvasLayer/Control.visible = true
	
func portraitBox():
	print('It is a portrait...')
	$CanvasLayer/Control.visible = true

func plateBox():
	print('It is a plate...')
	$CanvasLayer/Control.visible = true
	
func teapotBox():
	print('It is a teapot...')
	$CanvasLayer/Control.visible = true
	
func medallionBox():
	print('It is a medallion...')
	$CanvasLayer/Control.visible = true
		
func page1():
	print('It is a page1...')
	$CanvasLayer/Control.visible = true
		
func page2():
	print('It is a page2...')
	$CanvasLayer/Control.visible = true
	
func page3():
	print('It is a page3...')
	$CanvasLayer/Control.visible = true
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
