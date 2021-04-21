extends Popup

var default = [
	["Charles Darwin", 'Welcome to Edinburg!'],
	["Charles Darwin", 'Use the arrow keys to walk to a door, and press SPACE to enter.']
]

var monro = [
	["Alexander Monro", "Hello there. My name is Alexander Monro. I teach Anatomy."],
	["Alexander Monro", "What brings you here?"],	
	["Robert Morris", "Hello. My name is Robert Morris."],
	["Robert Morris", "I’m an acquaintance of Charles Darwin."],
	["Robert Morris", "I’ve come to do an interview about his life."],
	["Alexander Monro","I once overheard young Charles say that he thinks my lectures are dull."],
	["Alexander Monro","I suppose that explains his poor exam grades."],
	["Alexander Monro"," Over in that box you will find one of the bones I was lecturing on."],
	["Alexander Monro", "You can bring that back to him as a reminder that I have a bone to pick with him."]
]

var edmonstone = [
	["John Edmonstone", "Hello there. My name is John Edmonstone. I teach Taxidermy."],
	["John Edmonstone", "What brings you here?"],	
	["Robert Morris", "Hello. My name is Robert Morris."],
	["Robert Morris", "I’m an acquaintance of Charles Darwin."],
	["Robert Morris", "I’ve come to do an interview about his life."],
	["John Edmonstone","Charles told me about his grandfather Josiah, who created an anti-slavery medallion."],
	["John Edmonstone","And his Aunt Sarah, who made huge donations to the anti-slavery society."],
	["John Edmonstone"," At Charles’ church, they would say…"],
	["John Edmonstone", "The universal father has made of one blood all nations."],
	["John Edmonstone"," As someone formally enslaved, it was a joy to find that Charles Darwin was a strong abolitionist."],
	["John Edmonstone"," That is why I had a portrait of the two of us commissioned. "],
	["John Edmonstone"," You will find it in that box over there.."],
]

var jameson = [
	["Robert Jameson", "Hello there. My name is Robert Jameson. I teach Geology."],
	["Robert Jameson", "What brings you here?"],	
	["Robert Morris", "Hello. My name is Robert Morris."],
	["Robert Morris", "I’m an acquaintance of Charles Darwin."],
	["Robert Morris", "I’ve come to do an interview about his life."],
	["Robert Jameson","Charles sometimes falls asleep in my class."],
	["Robert Jameson","Perhaps you can get him to pay more attention. "],
	["Robert Jameson"," You are welcome to take one of my rocks as a reminder if you like."],
	["Robert Jameson"," Check in that box over there."],
]

var failBone = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a bone…"],	
	["Charles Darwin", "That has nothing to do with my abolitionist background."],
	["Charles Darwin", "You did all that time travel for nothing."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var failRocks = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a pile of rocks..."],	
	["Charles Darwin", "That has nothing to do with my abolitionist background."],
	["Charles Darwin", "You did all that time travel for nothing."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var successPortrait = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "It is a picture of you and John Edmonstone."],	
	["Charles Darwin", "That's it! He was well known for his opposition to slavery..."],
	["Charles Darwin", "having once been enslaved himself."],
	["Charles Darwin", "And he was my favorite teacher."],
	["Charles Darwin", "Now onto the second bit of evidence."],
	["Charles Darwin", "My Uncle Josiah could be of help to you."],
	["Charles Darwin", "Backin 1831, I received an invitation to go aboard The Beagle."],
	["Charles Darwin", "My father said no!"],
	["Charles Darwin", "So I went to Uncle Josiah to get help convincing my dad."],
	["Charles Darwin", "If anyone could vouch for me, it would be him."],
	["Robert Morris", "Wish me luck!"],	
]

var main = ""
var dialog_index = 0
var finished = false


func launch_popup():
	self.visible = true

func init_conversation(conversation):
	if conversation == "Monro":
		main = monro
	elif conversation == "Edmonstone":
		main = edmonstone
	elif conversation == "Jameson":
		main = jameson
	elif conversation =="FailBone":
		main = failBone
	elif conversation =="FailRocks":
		main = failRocks
	elif conversation =="SuccessPortrait":
		main = successPortrait
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
		if main == monro:
			var bone = get_node("/root/Level1/Bone")
			get_node("/root/Level1/Bone/CollisionShape2D").one_way_collision = false
			bone.visible = true
			var monroImages = get_node("/root/Level1/Monro/CanvasLayer/Control")
			monroImages.visible = false
		elif main == edmonstone:
			var portrait = get_node("/root/Level1/Portrait")
			portrait.visible = true
			get_node("/root/Level1/Portrait/CollisionShape2D").one_way_collision = false
			var edmonstoneImages = get_node("/root/Level1/Edmonstone/CanvasLayer/Control")
			edmonstoneImages.visible = false
		elif main == jameson:
			var rock = get_node("/root/Level1/Rocks")
			rock.visible = true
			get_node("/root/Level1/Rocks/CollisionShape2D").one_way_collision = false
			var jamesonImages = get_node("/root/Level1/Jameson/CanvasLayer/Control")
			jamesonImages.visible = false
		elif main == failBone:
			var room = get_node("/root/Level1/CanvasLayer/Courtroom")
			var bone = get_node("/root/Level1/Bone")
			room.visible = false
			bone.queue_free()
		elif main == failBone:
			var room = get_node("/root/Level1/CanvasLayer/Courtroom")
			var bone = get_node("/root/Level1/Bone")
			room.visible = false
			bone.queue_free()
		elif main == failRocks:
			var room = get_node("/root/Level1/CanvasLayer/Courtroom")
			var rocks = get_node("/root/Level1/Rocks")
			room.visible = false
			rocks.queue_free()
		elif main == successPortrait:
			var room = get_node("/root/Level1/CanvasLayer/Courtroom")
			var portrait = get_node("/root/Level1/Portrait")
			room.visible = false
			portrait.queue_free()
			var nextLevel = get_node("/root/Level1/CanvasLayer/NextLevel")
			nextLevel.visible = true
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true

