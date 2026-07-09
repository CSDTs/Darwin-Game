extends Node2D

# Level 2 mirrors Level 1's investigation flow: the player searches Uncle
# Josiah's house, collects all three artifacts into this level's own Case File,
# and only then may press F to return to the courtroom.

# Tracks which of Level 2's three artifacts have been collected.
var collected = {"Plate": false, "Teapot": false, "Medallion": false}

# Display names shown in the Case File for each artifact node.
var display_names = {"Plate": "Wedgwood Plate", "Teapot": "Wedgwood Teapot", "Medallion": "Anti-Slavery Medallion"}

onready var globals = get_node("/root/Globals")
onready var courtroom_prompt = get_node_or_null("/root/Level2/CanvasLayer/Control/CourtroomPrompt")

# True once all Level 2 evidence is collected: the player may now press F to
# return to the courtroom.
var ready_for_courtroom = false

# Called when the node enters the scene tree for the first time.
func _ready():

	var back = get_node("/root/Level2/CanvasLayer/Control/Button")

	back.connect("pressed", self, "_Button_pressed")

	# Level 2 shares the UI scene (whose baked text is the Level 1 objective), so
	# set the Level 2-specific objective here.
	var objective_panel = get_node("/root/Level2/CanvasLayer/Control/Objective")
	var objective = objective_panel.get_node("Label")
	objective.bbcode_text = "[center]Objective: Speak with Uncle Josiah and search the house for evidence of Darwin's abolitionist influences.[/center]"
	# This objective is longer than Level 1's and wraps to two lines, so grow the
	# bar and disable scrolling so the whole objective is readable without scrolling.
	objective.scroll_active = false
	objective_panel.margin_bottom = 74.0

	# Level 2 now has its own Case File, so show the "Press C" hint here too. This
	# runs after the shared UI script's _ready (children ready before parent), so
	# it overrides that script hiding the hint outside Level 1.
	var hint = get_node_or_null("/root/Level2/CanvasLayer/Control/CaseFileHint")
	if hint != null:
		hint.visible = true

	# The courtroom prompt is hidden until all evidence is collected (see _process).
	if courtroom_prompt != null:
		courtroom_prompt.visible = false
		var prompt_label = courtroom_prompt.get_node_or_null("Label")
		if prompt_label != null:
			prompt_label.bbcode_text = "[center]All evidence collected. Press F to return to the courtroom.[/center]"

	# Continue the collection flow once the player labels a freshly collected item.
	var case_file = get_node_or_null("/root/Level2/CaseFile")
	if case_file != null:
		case_file.connect("evidence_labeled", self, "_on_evidence_labeled")


#back button to main menu screen
func _Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

# Called by Item.gd when a Level 2 artifact is picked up. Marks the artifact as
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
	var case_file = get_node_or_null("/root/Level2/CaseFile")
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
		# Don't auto-return to the courtroom: let the player press F when ready.
		ready_for_courtroom = true

# Show the courtroom prompt only while the player is free to roam (hidden during
# the Case File, dialogue, etc.), and return to the courtroom when F is pressed.
func _process(delta):
	if courtroom_prompt != null:
		courtroom_prompt.visible = ready_for_courtroom and globals.canMove

func _unhandled_input(event):
	if ready_for_courtroom and globals.canMove:
		if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_F:
			_enter_courtroom()

# True only once the plate, teapot and medallion have all been collected.
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

# Returns to the courtroom using Level 2's existing transition structure: show
# the courtroom canvas and play the concluding conversation, which then reveals
# the "next level" screen (matching how Level 2 advanced before).
func _enter_courtroom():
	ready_for_courtroom = false
	if courtroom_prompt != null:
		courtroom_prompt.visible = false
	get_node("/root/Level2/CanvasLayer/Courtroom").visible = true
	var dialog = get_node("/root/Level2/CanvasLayer/Control/Popup")
	dialog.launch_conversation("Medallion")
