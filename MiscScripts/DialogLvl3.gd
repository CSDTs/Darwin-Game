extends Popup

var default = [
	["Charles Darwin", 'Welcome to the Beagle!'],
	["Charles Darwin", 'Try interacting with the captain by using SPACE.']
]

var captain = [
	["Robert Morris", " Hello! I believe you are Captain Fitzroy?"],
	["Captain Fitzroy", "Yes, I am. What brings you here?"],	
	["Robert Morris", "I’m a friend of Charles Darwin, and I'm here to hear his life story."],
	["Robert Morris", "What happened on the Beagle?"],
	["Captain Fitzroy","We argued often."],
	["Captain Fitzroy","He claimed that slave owners invented the myth that black people were an “other kind” of person, not true humans."],
	["Captain Fitzroy","Darwin’s view was the opposite: he said we are just one species."],
	["Captain Fitzroy","The humans-who adapted to different environments with skin color, height, and other trivial changes."],
	["Captain Fitzroy","You can find 3 of his notebooks in the boxes here."],
	["Captain Fitzroy","They cover many of his scientific theories and views."],
	["Robert Morris", "Thank you, Captain! It will be super helpful."],
]

var page1 = [
	["Robert Morris", "Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a journal entry about mollusca and vertebrate..."],	
	["Charles Darwin", "Unfortunately, it has nothing to do with my abolitionist background."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var page2 = [
	["Robert Morris", "Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a journal entry about tapirs..."],	
	["Charles Darwin", "Unfortunately, it has nothing to do with my abolitionist background."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var page3 = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "It’s the place in your journal where you show how slave owners were using a myth about Africans."],	
	["Charles Darwin", "That's it!"],
	["Charles Darwin", "That’s the journal page where I wrote about how slave owners justify their crimes."],
	["Charles Darwin", " They claim that white and black people are separate species."],
	["Robert Morris",  "But clearly all humans were once black, and Europeans adapted to the lack of sun with white skin."],
	["Charles Darwin", "That’s how the evolution concept first came to me."],
	["Robert Morris", "Now, I believe that I have enough evidence. We shall go back to the judge."],
	["Robert Morris", "Your honor, I bring back some photographic evidence that would prove Darwin is not the founder of racism."],
	["Robert Morris", "His theory of evolution actually comes from his abolitionist commitments."],	
	["Judge", "Please, elaborate on this."],	
	["Robert Morris", "Darwin’s family has been devoted to the anti-slavery cause, as you can see in this medalion."],	
	["Robert Morris", "Darwin himself is no less committed."],	
	["Robert Morris", "His journal mentioned John Edmondstone, a Black teacher at the University of Edinburgh..."],	
	["Robert Morris", "Proof that the black mind is equal to that of whites"],	
	["Robert Morris", "And most telling, he took the abolitionist idea--“we are all brothers and sisters”--as a model for human change in skin color."],	
	["Robert Morris", "Which then gave him a model for all animal change."],	
	["Robert Morris", "The very idea of evolution comes from Darwin’s strong anti-racist view."],	
	["Judge", "This is all the evidence I need. Mr. Morris, we truly appreciate your hard work to help us find out the truth."],	
	["Judge", " Mr. Darwin, we are sorry for the misunderstanding."],	
	["Judge", " From now on, everyone shall know of your research as science and social justice working hand in hand."],	
	["Charles Darwin", " Mr. Morris, thank you for your effort!"],	
]

var main = ""
var dialog_index = 0
var finished = false


func launch_popup():
	self.visible = true

func init_conversation(conversation):
	if conversation == "Captain":
		main = captain
	elif conversation =="Page1":
		main = page1
	elif conversation =="Page2":
		main = page2
	elif conversation =="Page3":
		main = page3
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
		if main == captain:
			var teapot = get_node("/root/Level3/Page1")
			var plate = get_node("/root/Level3/Page2")
			var medallion = get_node("/root/Level3/Page3")
			teapot.visible = true
			plate.visible = true
			medallion.visible = true
			var uncleImages = get_node("/root/Level3/Captain/CanvasLayer/Control")
			uncleImages.visible = false
		elif main == page1:
			var room = get_node("/root/Level3/CanvasLayer/Courtroom")
			var teapot = get_node("/root/Level3/Page1")
			room.visible = false
			teapot.queue_free()
		elif main == page2:
			var room = get_node("/root/Level3/CanvasLayer/Courtroom")
			var plate = get_node("/root/Level3/Page2")
			room.visible = false
			plate.queue_free()
		elif main == page3:
			var room = get_node("/root/Level3/CanvasLayer/Courtroom")
			var medallion = get_node("/root/Level3/Page3")
			room.visible = false
			medallion.queue_free()
			var nextLevel = get_node("/root/Level3/CanvasLayer/NextLevel")
			nextLevel.visible = true
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true
