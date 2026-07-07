extends Node2D

# Tracks which of Level 1's three artifacts have been collected.
var collected = {"Bone": false, "Rocks": false, "Portrait": false}

# Display names shown in the Case File for each artifact node.
var display_names = {"Bone": "Bone", "Rocks": "Plinian Society Note", "Portrait": "Portrait"}

onready var globals = get_node("/root/Globals")
onready var courtroom_prompt = get_node_or_null("/root/Level1/CanvasLayer/Control/CourtroomPrompt")

# True once all evidence is collected: the player may now press F to enter court.
var ready_for_courtroom = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var back = get_node("/root/Level1/CanvasLayer/Control/Button")
	back.connect("pressed", self, "_Button_pressed")
	var case_file = get_node_or_null("/root/Level1/CaseFile")
	if case_file != null:
		case_file.connect("evidence_labeled", self, "_on_evidence_labeled")

#back button to main menu screen
func _Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

# Called by Item.gd when a Level 1 artifact is picked up. Marks the artifact as
# collected and opens the Case File so the player can label it. The collection
# flow continues once labeling is done (see _on_evidence_labeled).
func collect_artifact(item):
	var art_name = item.name
	if collected.has(art_name):
		collected[art_name] = true
	# Reuse the artifact's own image (the sprite shown in its world pickup preview).
	var art_texture = null
	var art_sprite = item.get_node_or_null("CanvasLayer/Control/" + art_name)
	if art_sprite != null:
		art_texture = art_sprite.texture
	item.queue_free()
	var case_file = get_node_or_null("/root/Level1/CaseFile")
	if case_file != null:
		var shown_name = art_name
		if display_names.has(art_name):
			shown_name = display_names[art_name]
		case_file.open_label_mode(shown_name, art_texture, art_name)
	else:
		_after_label()

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
