extends Popup

var default = [
	["Charles Darwin", 'Welcome to my Uncle Josaiah\'s house!'],
	["Charles Darwin", 'Try interacting with him by using SPACE.']
]

var uncle = [
	["Josaiah Wedgewood", "Hello there. My name is Josaiah Wedgewood."],
	["Josaiah Wedgewood", "What seems to bring you to my home on this fine day?"],	
	["Robert Morris", "Hello. My name is Robert Morris."],
	["Robert Morris", "I’m an acquaintance of your nephew Charles Darwin."],
	["Robert Morris", "He said he missed home, and asked me to bring back some reminder of his life."],
	["Josaiah Wedgewood","Well you are welcome to take anything in the room."],
	["Josaiah Wedgewood","I don’t have much use for this stuff any more."],
]

var failTeapot = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a teapot..."],	
	["Charles Darwin", "That has nothing to do with my abolitionist background."],
	["Charles Darwin", "You did all that time travel for nothing."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var failPlate = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a plate..."],	
	["Charles Darwin", "That has nothing to do with my abolitionist background."],
	["Charles Darwin", "You did all that time travel for nothing."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var successMedallion = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is some sort of medallion."],	
	["Charles Darwin", "That's it!"],
	["Charles Darwin", "The anti-slavery medallion from my great grandfather, (also named Josiah)."],
	["Charles Darwin", "Clear evidence if there ever was one."],
	["Robert Morris",  "Where else can I find evidence to help you prove your abolitionist background?"],
	["Charles Darwin", "The last place that comes to my mind is the Beagle."],
	["Charles Darwin", "Would you mind making a stop there and chat with Captain Fitzroy?"],
	["Charles Darwin", "He definitely will prove a lot of useful information for you."],
	["Robert Morris", "Sure! It\'s time for me to go. I\'ll be back shortly."],	
]

var main = ""
var dialog_index = 0
var finished = false


func launch_popup():
	self.visible = true

func init_conversation(conversation):
	if conversation == "Uncle":
		main = uncle
	elif conversation =="FailTeapot":
		main = failTeapot
	elif conversation =="FailPlate":
		main = failPlate
	elif conversation =="SuccessMedallion":
		main = successMedallion
	dialog_index = 0
	finished = false	
	
func _ready():
	main = default
	self.visible = true
	load_dialog()
	
func _process(delta):
	$"next-indicator".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if self.visible == true:
			load_dialog()

func load_dialog():
	if dialog_index < main.size():
		finished = false
		$"dialog-text".bbcode_text = main[dialog_index][1]
		$"dialog-text".percent_visible = 0
		$Tween.interpolate_property($"dialog-text", "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		$"name-label".bbcode_text = main[dialog_index][0]
	else:
		#queue_free()
		self.visible = false
		if main == uncle:
			var teapot = get_node("/root/Level2/Teapot")
			var plate = get_node("/root/Level2/Plate")
			var medallion = get_node("/root/Level2/Medallion")
			teapot.visible = true
			plate.visible = true
			medallion.visible = true
			var uncleImages = get_node("/root/Level2/Uncle/CanvasLayer/Control")
			uncleImages.visible = false
		elif main == failTeapot:
			var room = get_node("/root/Level2/CanvasLayer/Courtroom")
			var teapot = get_node("/root/Level2/Teapot")
			room.visible = false
			teapot.queue_free()
		elif main == failPlate:
			var room = get_node("/root/Level2/CanvasLayer/Courtroom")
			var plate = get_node("/root/Level2/Plate")
			room.visible = false
			plate.queue_free()
		elif main == successMedallion:
			var room = get_node("/root/Level2/CanvasLayer/Courtroom")
			var medallion = get_node("/root/Level2/Medallion")
			room.visible = false
			medallion.queue_free()
			var nextLevel = get_node("/root/Level2/CanvasLayer/NextLevel")
			nextLevel.visible = true
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true
