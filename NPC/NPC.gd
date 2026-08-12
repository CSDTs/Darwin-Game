extends KinematicBody2D

onready var node = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var hint = $Area2D/Control
onready var item

# For Uncle / Captain: true once their opening conversation has been started. The
# intro is gated on this flag rather than on artifact visibility, because Level 2's
# artifacts are visible from the start (so the old "any hidden" test never fired
# and Uncle's intro never launched).
var intro_done = false

func _ready():
	if self.name == "Monro":
		$Monro.visible = true
		item = get_node("/root/Level1/Bone")
		$CanvasLayer/Control/Monro.visible = true
		hint.get_node("RichTextLabel").bbcode_text = "[center]Anatomy Classroom\nProfessor Monro - press F to talk[/center]"
	elif self.name == 'Jameson':
		$Jameson.visible = true
		item = get_node("/root/Level1/Rocks")
		$CanvasLayer/Control/Jameson.visible = true
		hint.get_node("RichTextLabel").bbcode_text = "[center]Natural History Lecture Hall\nProfessor Jameson - press F to talk[/center]"
	elif self.name == "Edmonstone":
		$Edmonstone.visible = true
		item = get_node("/root/Level1/Portrait")
		$CanvasLayer/Control/Edmonstone.visible = true
		hint.get_node("RichTextLabel").bbcode_text = "[center]Specimen Room\nProfessor Edmonstone - press F to talk[/center]"
	elif self.name == "Uncle":
		$Uncle.visible = true
		item = [get_node("/root/Level2/Teapot"), get_node("/root/Level2/Plate"), get_node("/root/Level2/Medallion")]
		$CanvasLayer/Control/Uncle.visible = true
	elif self.name == "Captain":
		$Captain.visible = true
		item = [get_node("/root/Level3/Page1"), get_node("/root/Level3/Page2"), get_node("/root/Level3/Page3")]
		$CanvasLayer/Control/Captain.visible = true

	# Give the small interaction prompt this professor's role/name (two-line).
	var role = ""
	if self.name == "Monro":
		role = "Anatomy Professor - Monro"
	elif self.name == "Jameson":
		role = "Natural History Professor - Jameson"
	elif self.name == "Edmonstone":
		role = "Taxidermy Teacher - Edmonstone"
	var prompt = get_node_or_null("InteractionPrompt")
	if prompt != null:
		prompt.set_prompt(role, "Press Space to talk")

# Returns the conversation this NPC should play right now, or "" if it has nothing
# to say (e.g. Uncle after his one-time intro). Used for BOTH the prompt (can_talk)
# and the actual interaction, so the prompt and interaction always agree.
func _which_conversation():
	if self.name == "Uncle":
		# Uncle Josiah: a single one-time conversation. Nothing afterwards.
		if intro_done:
			return ""
		return "Uncle"
	elif self.name == "Captain":
		# Level 3 is a two-step Captain flow, driven by the Level 3 script's state:
		#   1) the intro plays first (before FitzRoy has been spoken to),
		#   2) after ALL pages are collected the Captain becomes interactable again for
		#      the "return with the evidence" line, which then sends the player to court.
		# In between (during collection) he has nothing to say (no prompt).
		var level3 = get_node_or_null("/root/Level3")
		if level3 == null:
			return ""
		if not level3.has_spoken_to_fitzroy:
			return "Captain"
		if level3.all_evidence_collected() and not level3.fitzroy_return_done:
			return "CaptainReturn"
		return ""
	else:
		# Level 1 professors. item is their single artifact node.
		if is_instance_valid(item):
			if item.visible != true:
				return self.name          # opening (leads to the question menu)
			return ""                     # unlocked but not yet collected -> nothing
		return self.name + "After"         # collected -> short repeat line

# True while the NPC has something to say; drives the "Press Space to talk" prompt.
func can_talk():
	return _which_conversation() != ""

# Launches the current conversation. Called when the player presses Space inside
# this NPC's talk area (no facing required).
func start_conversation():
	var convo = _which_conversation()
	if convo == "":
		return
	node.init_conversation(convo)
	node.launch_popup()
	$CanvasLayer/Control.visible = true
	if convo == self.name:
		# The opening / intro line: hide the small hint and, for the one-time NPCs,
		# mark the intro as done so the prompt stops appearing for them.
		hint.visible = false
		if self.name == "Uncle" or self.name == "Captain":
			intro_done = true
