extends Node2D

# Tracks which of Level 1's three artifacts have been collected.
var collected = {"Bone": false, "Rocks": false, "Portrait": false}

# Display names shown in the Case File for each artifact node.
var display_names = {"Bone": "Bone", "Rocks": "Plinian Society Note", "Portrait": "Portrait"}

# Evidence-card copy per artifact: card name, fixed strength, what it is, and why
# it matters. Reuses the same EvidenceCard as Level 2.
var card_content = {
	"Bone": {
		"name": "Bone",
		"strength": "Weak",
		"shows": "Darwin studied anatomy and learned about the structure of living beings.",
		"why": "This gives background on Darwin's scientific education, but it does not directly prove his abolitionist beliefs."
	},
	"Rocks": {
		"name": "Rocks",
		"strength": "Weak",
		"shows": "Darwin studied natural history and geology in Edinburgh.",
		"why": "This shows Darwin's early scientific training, but it does not directly answer the accusation about racism or slavery."
	},
	"Portrait": {
		"name": "Portrait of Darwin and John Edmonstone",
		"strength": "Strong",
		"shows": "Darwin learned from John Edmonstone, a formerly enslaved man who opposed slavery.",
		"why": "This connects Darwin to an early abolitionist influence and helps show that Darwin was shaped by people who rejected slavery and racial hierarchy."
	}
}

onready var globals = get_node("/root/Globals")
onready var courtroom_prompt = get_node_or_null("/root/Level1/CanvasLayer/Control/CourtroomPrompt")
onready var evidence_card = get_node_or_null("/root/Level1/EvidenceCard")

# The artifact whose evidence card is currently open, held until the player
# continues (then it is added to the Case File).
var _pending_item = null
var _pending_texture = null

# True once all evidence is collected: the player may now press F to enter court.
var ready_for_courtroom = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var back = get_node("/root/Level1/CanvasLayer/Control/Button")
	back.connect("pressed", self, "_Button_pressed")
	var case_file = get_node_or_null("/root/Level1/CaseFile")
	if case_file != null:
		case_file.connect("evidence_labeled", self, "_on_evidence_labeled")
	# The evidence card's Continue button adds the artifact to the Case File.
	if evidence_card != null:
		evidence_card.connect("continued", self, "_on_card_continued")

#back button to main menu screen
func _Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

# Called by Item.gd when a Level 1 artifact is picked up. Marks the artifact as
# collected and opens the Case File so the player can label it. The collection
# flow continues once labeling is done (see _on_evidence_labeled).
func collect_artifact(item):
	# Show the evidence card first; the artifact is added to the Case File once the
	# player continues from the card (see _on_card_continued).
	if _pending_item != null:
		return
	_pending_item = item
	var art_name = item.name
	# Reuse the artifact's own image (the sprite shown in its world pickup preview).
	var tex = null
	var art_sprite = item.get_node_or_null("CanvasLayer/Control/" + art_name)
	if art_sprite != null:
		tex = art_sprite.texture
	_pending_texture = tex
	if evidence_card == null:
		# No card available: collect directly (keeps the old behaviour working).
		_on_card_continued()
		return
	var content = card_content[art_name] if card_content.has(art_name) else {}
	var card_name = content["name"] if content.has("name") else art_name
	var shows_text = content["shows"] if content.has("shows") else ""
	var why_text = content["why"] if content.has("why") else ""
	var strength = content["strength"] if content.has("strength") else ""
	var strength_text = ("Evidence Strength: " + strength + " Evidence") if strength != "" else ""
	evidence_card.show_card(card_name, tex, shows_text, why_text, strength_text)

# Continue pressed on the evidence card: mark the artifact collected, add it to the
# Case File with its fixed strength, and resume movement.
func _on_card_continued():
	var item = _pending_item
	_pending_item = null
	if item == null:
		return
	var art_name = item.name
	if collected.has(art_name):
		collected[art_name] = true
	item.queue_free()
	globals.canMove = true
	var content = card_content[art_name] if card_content.has(art_name) else {}
	var strength = content["strength"] if content.has("strength") else "Weak"
	var desc = content["shows"] if content.has("shows") else ""
	var case_file = get_node_or_null("/root/Level1/CaseFile")
	if case_file != null:
		var shown_name = display_names[art_name] if display_names.has(art_name) else art_name
		case_file.add_evidence(shown_name, _pending_texture, art_name, strength, desc)
	else:
		_after_label()
	_pending_texture = null

# Runs once the player has labelled the freshly collected evidence.
func _on_evidence_labeled(evidence_name, strength):
	_after_label()

func _after_label():
	if all_evidence_collected():
		# Don't auto-enter the courtroom: let the player press F when ready.
		ready_for_courtroom = true
		var objective = get_node("/root/Level1/CanvasLayer/Control/Objective/Label")
		objective.bbcode_text = "[center]Objective complete.[/center]"
	else:
		_update_progress()

# Show the courtroom prompt only while the player is free to roam (hidden during
# the Case File, dialogue, etc.), and enter the courtroom when F is pressed.
func _process(delta):
	if courtroom_prompt != null:
		courtroom_prompt.visible = ready_for_courtroom and globals.canMove

func _unhandled_input(event):
	if ready_for_courtroom and globals.canMove:
		if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_F:
			ready_for_courtroom = false
			if courtroom_prompt != null:
				courtroom_prompt.visible = false
			_show_completion()

# True only once the bone, rock and portrait have all been collected.
func all_evidence_collected():
	for key in collected:
		if collected[key] == false:
			return false
	return true

func _collected_count():
	var count = 0
	for key in collected:
		if collected[key]:
			count += 1
	return count

# Per-pickup feedback shown in the objective bar while evidence is still missing.
func _update_progress():
	var objective = get_node("/root/Level1/CanvasLayer/Control/Objective/Label")
	objective.bbcode_text = "[center]Evidence collected: " + str(_collected_count()) + "/3. Keep searching Edinburgh.[/center]"

# Runs once all three artifacts are collected: shows the message and unlocks the
# courtroom transition (which then leads on to the next level as before).
func _show_completion():
	get_node("/root/Level1/CanvasLayer/Courtroom").visible = true
	var dialog = get_node("/root/Level1/CanvasLayer/Control/Popup")
	dialog.launch_conversation("Level1Complete")
