extends Popup

var dialog = [
	['...', 'Charles Darwin... (PRESS SPACE TO CONTINUE)'],
	['Time Travel Court','We are the Time Travel Court.'],
	['Time Travel Court','You have been transported to the year 2093 to stand trial.'],
	['Time Travel Court','The prosecution claims you invented the theory of evolution to support racism.'],
	['Charles Darwin','That\'s ridiculous. I have been an abolitionist all my life, dedicated to opposing white supremacy.'],
	['Charles Darwin','Evolution was intended to show that people of all colors are equally human.'],
	['Robert Morris','Greetings! I am your court appointed lawyer, Robert Morris.'],
	['Robert Morris','What evidence do you have of your abolitionist background?'],
	['Charles Darwin','First stop is my school, Edinburgh.'],
	['Charles Darwin','Chat with the 3 professors in the classrooms.'],
	['Charles Darwin','You\'ll know the evidence when you see it.']
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
		$"dialog-text".bbcode_text = dialog[dialog_index][1]
		$"name-label".bbcode_text = dialog[dialog_index][0]
		$"dialog-text".percent_visible = 0
		$Tween.interpolate_property($"dialog-text", "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

		#$DarwinTween.interpolate_property($"darwin", "modulate", Color(1, 1, 1, 1), Color(0.5, 0.5, 0.5, 1),  0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
		if dialog_index == 0:
			$JudgeTween.interpolate_property($"judge", "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$DarwinTween.interpolate_property($"darwin", "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1),  0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$BackgroundTween.interpolate_property($"background", "modulate", Color(0, 0, 0, 1), Color(1, 1, 1, 1),  0.8,Tween.TRANS_LINEAR, Tween.EASE_IN)
			$BackgroundTween.start()
			$JudgeTween.start()
			$DarwinTween.start()
		if dialog_index == 6:
			$JudgeTween.interpolate_property($"judge", "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$MorrisTween.interpolate_property($"lawyer", "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$JudgeTween.start()
			$MorrisTween.start()
		#if dialog_index > 3 && dialog_index <=4:
			#$DarwinTween.interpolate_property($"darwin", "modulate", Color(0.5, 0.5, 0.5, 1), Color(1, 1, 1, 1),  0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			#$DarwinTween.start()
	else:
		queue_free()
		get_tree().change_scene("res://Level1.tscn")
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true


func _on_JudgeTween_tween_completed(object, key):
	pass # Replace with function body.


func _on_DarwinTween_tween_completed(object, key):
	pass # Replace with function body.


func _on_BackgroundTween_tween_completed(object, key):

	pass # Replace with function body.


func _on_MorrisTween_tween_completed(object, key):
	pass # Replace with function body.
