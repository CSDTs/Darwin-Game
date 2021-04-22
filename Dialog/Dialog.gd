extends Popup

onready var globals = get_node("/root/Globals")
onready var main = ""

var lvl1 = [
	["[center]Charles Darwin[/center]", 'Welcome to Edinburg!'],
	["[center]Charles Darwin[/center]", 'Use the arrow keys to walk to a door, and press SPACE to enter.']
]

var lvl2 = [
	["Charles Darwin", 'Welcome to my Uncle Josaiah\'s house!'],
	["Charles Darwin", 'Try interacting with him by using SPACE.']
]

var lvl3 = [
	["Charles Darwin", 'Welcome to the Beagle!'],
	["Charles Darwin", 'Try interacting with the captain by using SPACE.']
]



var monro = [
	["[center]Alexander Monro[/center]", "Hello there. My name is Alexander Monro. I teach Anatomy."],
	["[center]Alexander Monro[/center]", "What brings you here?"],	
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris."],
	["[center]Robert Morris[/center]", "I’m an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I’ve come to do an interview about his life."],
	["[center]Alexander Monro[/center]","I once overheard young Charles say that he thinks my lectures are dull."],
	["[center]Alexander Monro[/center]","I suppose that explains his poor exam grades."],
	["[center]Alexander Monro[/center]"," Over in that box you will find one of the bones I was lecturing on."],
	["[center]Alexander Monro[/center]", "You can bring that back to him as a reminder that I have a bone to pick with him."]
]

var edmonstone = [
	["[center]John Edmonstone[/center]", "Hello there. My name is John Edmonstone. I teach Taxidermy."],
	["[center]John Edmonstone[/center]", "What brings you here?"],	
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris."],
	["[center]Robert Morris[/center]", "I’m an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I’ve come to do an interview about his life."],
	["[center]John Edmonstone[/center]","Charles told me about his grandfather Josiah, who created an anti-slavery medallion."],
	["[center]John Edmonstone[/center]","And his Aunt Sarah, who made huge donations to the anti-slavery society."],
	["[center]John Edmonstone[/center]"," At Charles’ church, they would say…"],
	["[center]John Edmonstone[/center]", "The universal father has made of one blood all nations."],
	["[center]John Edmonstone[/center]"," As someone formally enslaved, it was a joy to find that Charles Darwin was a strong abolitionist."],
	["[center]John Edmonstone[/center]"," That is why I had a portrait of the two of us commissioned. "],
	["[center]John Edmonstone[/center]"," You will find it in that box over there.."],
]

var jameson = [
	["[center]Robert Jameson[/center]", "Hello there. My name is Robert Jameson. I teach Geology."],
	["[center]Robert Jameson[/center]", "What brings you here?"],	
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris."],
	["[center]Robert Morris[/center]", "I’m an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I’ve come to do an interview about his life."],
	["[center]Robert Jameson[/center]","Charles sometimes falls asleep in my class."],
	["[center]Robert Jameson[/center]","Perhaps you can get him to pay more attention. "],
	["[center]Robert Jameson[/center]"," You are welcome to take one of my rocks as a reminder if you like."],
	["[center]Robert Jameson[/center]"," Check in that box over there."],
]

var failBone = [
	["[center]Robert Morris[/center]", "Well Mr. Darwin, I hope this is the evidence we need."],
	["[center]Robert Morris[/center]", "I think it is a bone…"],	
	["[center]Charles Darwin[/center]", "That has nothing to do with my abolitionist background."],
	["[center]Charles Darwin[/center]", "You did all that time travel for nothing."],
	["[center]Robert Morris[/center]", "Sorry about that. Let me try again."],	
]
var failRocks = [
	["[center]Robert Morris[/center]", "Well Mr. Darwin, I hope this is the evidence we need."],
	["[center]Robert Morris[/center]", "I think it is a pile of rocks..."],	
	["[center]Charles Darwin[/center]", "That has nothing to do with my abolitionist background."],
	["[center]Charles Darwin[/center]", "You did all that time travel for nothing."],
	["[center]Robert Morris[/center]", "Sorry about that. Let me try again."],	
]
var successPortrait = [
	["[center]Robert Morris[/center]", "Well Mr. Darwin, I hope this is the evidence we need."],
	["[center]Robert Morris[/center]", "It is a picture of you and John Edmonstone."],	
	["[center]Charles Darwin[/center]", "That's it! He was well known for his opposition to slavery..."],
	["[center]Charles Darwin[/center]", "having once been enslaved himself."],
	["[center]Charles Darwin[/center]", "And he was my favorite teacher."],
	["[center]Charles Darwin[/center]", "Now onto the second bit of evidence."],
	["[center]Charles Darwin[/center]", "My Uncle Josiah could be of help to you."],
	["[center]Charles Darwin[/center]", "Backin 1831, I received an invitation to go aboard The Beagle."],
	["[center]Charles Darwin[/center]", "My father said no!"],
	["[center]Charles Darwin[/center]", "So I went to Uncle Josiah to get help convincing my dad."],
	["[center]Charles Darwin[/center]", "If anyone could vouch for me, it would be him."],
	["[center]Robert Morris[/center]", "Wish me luck!"],	
]

var monroAfter = [
	["[center]Alexander Monro[/center]", "I'm sorry Mr. Morris, but I have nothing left to offer."],
	["[center]Alexander Monro[/center]", "Perhaps the Taxidermy or Geology professors might have more to offer..."],	
]

var jamesonAfter = [
	["[center]Robert Jameson[/center]", "I'm sorry Mr. Morris, but I have nothing left to offer."],
	["[center]Robert Jameson[/center]", "Perhaps the Taxidermy or Anatomy professors might have more to offer..."],	
]

var uncleAfter = [
	["[center]Robert Jameson[/center]", "I'm sorry Mr. Morris, but I have nothing left to offer."],
	["[center]Robert Jameson[/center]", "Perhaps the Taxidermy or Anatomy professors might have more to offer..."],	
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

var failedAttempt = [
	["Josaiah Wedgewood", "Hello again, Mr. Morris. Not what you were looking for?"],
	["Josaiah Wedgewood", "I'm sure I have a few more items laying around."],	
	["Josaiah Wedgewood", "Why don\'t you try something else?"],	
]


var failedAttempt2 = [
	["Captain Fitzroy", "Hello again, Mr. Morris. Not what you were looking for?"],
	["Captain Fitzroy", "I'm sure I have a few more items laying around the boat."],	
	["Captain Fitzroy", "Why don\'t you try another journal?"],	
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
var dialog_index = 0
var finished = false


func launch_conversation(name):
	init_conversation(name)
	launch_popup()
	load_dialog()

func launch_popup():
	globals.canMove = false
	self.visible = true

func init_conversation(conversation):
	if conversation == "Monro":
		main = monro
	elif conversation == "MonroAfter":
		main = monroAfter
	elif conversation == "JamesonAfter":
		main = jamesonAfter
	elif conversation == "Edmonstone":
		main = edmonstone
	elif conversation == "Jameson":
		main = jameson
	elif conversation =="Bone":
		main = failBone
	elif conversation =="Rocks":
		main = failRocks
	elif conversation =="Portrait":
		main = successPortrait
	elif conversation == "Uncle":
		main = uncle
	elif conversation =="Teapot":
		main = failTeapot
	elif conversation =="Plate":
		main = failPlate
	elif conversation =="Medallion":
		main = successMedallion
	elif conversation =="UncleAfter":
		main = failedAttempt
	elif conversation == "Captain":
		main = captain
	elif conversation =="CaptainAfter":
		main = failedAttempt2
	elif conversation =="Page1":
		main = page1
	elif conversation =="Page2":
		main = page2
	elif conversation =="Page3":
		main = page3
	
	dialog_index = 0
	finished = false	
	
func _ready():
	if get_tree().get_current_scene().get_name() == "Level1":
		main = lvl1
	elif get_tree().get_current_scene().get_name() == "Level2":
		main = lvl2
	elif get_tree().get_current_scene().get_name() == "Level3":
		main = lvl3
	self.visible = true
	globals.canMove = false
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
		$"name-label".bbcode_text = main[dialog_index][0]
		$"dialog-text".percent_visible = 0
		$Tween.interpolate_property($"dialog-text", "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		self.visible = false
		globals.canMove = true
	
		if main == monro:
			get_node("/root/Level1/Bone").visible = true
			get_node("/root/Level1/Bone/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Monro/CanvasLayer/Control").visible = false
		elif main == jameson:
			get_node("/root/Level1/Rocks").visible = true
			get_node("/root/Level1/Rocks/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Jameson/CanvasLayer/Control").visible = false
		elif main == edmonstone:
			get_node("/root/Level1/Portrait").visible = true
			get_node("/root/Level1/Portrait/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Edmonstone/CanvasLayer/Control").visible = false
		elif main == monroAfter:
			get_node("/root/Level1/Monro/CanvasLayer/Control").visible = false
		elif main == jamesonAfter:
			get_node("/root/Level1/Jameson/CanvasLayer/Control").visible = false
		elif main == failedAttempt:
			get_node("/root/Level2/Uncle/CanvasLayer/Control").visible = false
		elif main == failedAttempt2:
			get_node("/root/Level3/Captain/CanvasLayer/Control").visible = false
		elif main == failRocks:
			get_node("/root/Level1/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level1/Rocks").queue_free()
		elif main == failBone:
			get_node("/root/Level1/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level1/Bone").queue_free()
		elif main == successPortrait:
			get_node("/root/Level1/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level1/Portrait").queue_free()
			get_node("/root/Level1/CanvasLayer/NextLevel").visible = true	
		elif main == uncle:
			get_node("/root/Level2/Teapot").visible = true
			get_node("/root/Level2/Teapot/CollisionShape2D").one_way_collision = false
			get_node("/root/Level2/Plate").visible = true
			get_node("/root/Level2/Plate/CollisionShape2D").one_way_collision = false
			get_node("/root/Level2/Medallion").visible = true
			get_node("/root/Level2/Medallion/CollisionShape2D").one_way_collision = false
			get_node("/root/Level2/Uncle/CanvasLayer/Control").visible = false
		elif main == failTeapot:
			get_node("/root/Level2/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level2/Teapot").queue_free()
		elif main == failPlate:
			get_node("/root/Level2/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level2/Plate").queue_free()
		elif main == successMedallion:
			get_node("/root/Level2/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level2/Medallion").queue_free()
			get_node("/root/Level2/CanvasLayer/NextLevel").visible = true
		elif main == captain:
			get_node("/root/Level3/Page1").visible = true
			get_node("/root/Level3/Page1/CollisionShape2D").one_way_collision = false
			get_node("/root/Level3/Page2").visible = true
			get_node("/root/Level3/Page2/CollisionShape2D").one_way_collision = false
			get_node("/root/Level3/Page3").visible = true
			get_node("/root/Level3/Page3/CollisionShape2D").one_way_collision = false
			get_node("/root/Level3/Captain/CanvasLayer/Control").visible = false
		elif main == page1:
			get_node("/root/Level3/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level3/Page1").queue_free()
		elif main == page2:
			get_node("/root/Level3/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level3/Page2").queue_free()
		elif main == page3:
			get_node("/root/Level3/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level3/Page3").queue_free()
			get_node("/root/Level3/CanvasLayer/NextLevel").visible = true
			
	dialog_index += 1

func _on_Tween_tween_completed(object, key):
	finished = true
	
