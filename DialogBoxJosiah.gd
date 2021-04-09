extends Control

var dialog = [
	'My Name is Josiah Wedgwood. What brings you here',
	'Hello. My name is Robert Morris and I am an acquaintance of your nephew Charles Darwin. He said he missed home, and asked me to bring back some reminder of his life.',
	'Well you are welocme to take anything in the room, I do not have much use for this stuff anymore.']
var dialog_index = 0
var finished = false

func _ready():
	$PatCharacter.visible = true
	$JosiahWedgwood.visible = true
	load_dialog()

func _process(delta):
	$"next-indicator".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		load_dialog()

func load_dialog():
	if dialog_index < dialog.size():
		finished = false
		if dialog_index%2 != 0:
#			self.rect_position.x = 465
			$TextureRect.rect_position.x = 250
			$RichTextLabel.rect_position.x = 265
			$"next-indicator".position.x = 600
		else: 
#			self.rect_position.x = 265
			$TextureRect.rect_position.x = 0
			$RichTextLabel.rect_position.x = 15
			$"next-indicator".position.x = 250
		$RichTextLabel.bbcode_text = dialog[dialog_index]
		$RichTextLabel.percent_visible = 0
		$Tween.interpolate_property(
			$RichTextLabel, "percent_visible", 0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
	else:
		queue_free()
		$PatCharacter.visible = false
		$JosiahWedgwood.visible = false
	dialog_index += 1
	
#func _process(delta):
#	#next indicator shows when text box finishes typing
#	$"next-indicator".visible = true
#	if Input.is_action_just_pressed("ui_accept") && finished == false: 
#		#when any key is pressed, moves onto next dialog
#		load_dialog()
#
#func load_dialog():
#	if (dialogIndex < dialog.size()):
#		finished = false
#		self.visible = true
#		$RichTextLabel.bbcode_text = dialog[dialogIndex]
#		$RichTextLabel.percent_visible = 0
#		#makes text type out one letter at a time
#		$Tween.interpolate_property($RichTextLabel,
#		"percent_visible",0,1,1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		$Tween.start()
#	else:
#		queue_free() #remove dialog
#	dialogIndex += 1

func _on_Tween_tween_completed(object, key):
	finished = true # Replace with function body.
