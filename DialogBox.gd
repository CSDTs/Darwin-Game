extends Popup

var dialog = [
	'Charles Darwin...',
	'We are the Time Travel Court.',
	'You have been transported to the year 2093 to stand trial.',
	'The prosecution claims you invented the theory of evolution to support racism.',
	'That\'s ridiculous. I have been an abolitionist all my life, dedicated to opposing white supremacy.',
	'Evolution was intended to show that people of all colors are equally human.',
	'Greetings! I am your court appointed lawyer, Robert Morris.',
	'What evidence do you have of your abolitionist background?',
	'First stop is my school, Edinburgh.',
	'Chat with the 3 professors in the classrooms.',
	'You\'ll know the evidence when you see it.'
]

var speaker = [
	"Time Travel Court", 
	"Charles Darwin", 
	"Robert Morris", 
]

var dialog_index = 0
var finished = false

func _ready():
	show()
	load_dialog()
	
func _process(delta):
	$"next-indicator".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		load_dialog()
	
func load_dialog():
	if dialog_index < dialog.size():
		finished = false
		$"dialog-text".bbcode_text = dialog[dialog_index]
		$"dialog-text".percent_visible = 0
		$Tween.interpolate_property($"dialog-text", "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
#		$Tween2.interpolate_property($"judge", "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
		if dialog_index < 4:
			#if dialog_index == 0:
				#$Tween2.start()
			$"name-label".bbcode_text = speaker[0]
		elif dialog_index == 6 || dialog_index == 7:
			$"name-label".bbcode_text = speaker[2]
		else:
			$"name-label".bbcode_text = speaker[1]
	else:
		queue_free()
		get_tree().change_scene("res://Level1.tscn")
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true


func _on_Tween2_tween_completed(object, key):
	pass # Replace with function body.
