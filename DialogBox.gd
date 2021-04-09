extends Control

var dialog = ['','hi','continue','bye']
var dialogIndex = 0
var finished = true

func _ready():
	self.visible = false
#	if finished == false:
#		load_dialog()
	pass

func _process(delta):
	#next indicator shows when text box finishes typing
	$"next-indicator".visible = true
	if Input.is_action_just_pressed("ui_accept") && finished == false: 
		#when any key is pressed, moves onto next dialog
		load_dialog()
		
func load_dialog():
	if (dialogIndex < dialog.size()):
		finished = false
		self.visible = true
		$RichTextLabel.bbcode_text = dialog[dialogIndex]
		$RichTextLabel.percent_visible = 0
		#makes text type out one letter at a time
		$Tween.interpolate_property($RichTextLabel,
		"percent_visible",0,1,1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		queue_free() #remove dialog
	dialogIndex += 1
	
func _on_Tween_tween_completed(object, key):
#	finished = true
	pass

func _on_Josiah_body_entered(body):
	if body.name == 'Player':
		finished = false
		dialogIndex = 1 
		load_dialog() 

func _on_Josiah_body_exited(body):
	dialogIndex = 0 
	finished = true
	self.visible = false
