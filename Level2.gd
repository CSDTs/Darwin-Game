extends Node2D

# Level 2 mirrors Level 1's investigation flow: the player searches Uncle
# Josiah's house, collects all three artifacts into this level's own Case File,
# and only then may press F to return to the courtroom.

# Tracks which of Level 2's three artifacts have been collected.
var collected = {"Plate": false, "Teapot": false, "SermonNotes": false, "Medallion": false}

# Display names shown in the Case File for each artifact node.
var display_names = {"Plate": "Regular Plate", "Teapot": "Teapot", "SermonNotes": "\"One Blood\" Sermon Notes", "Medallion": "Anti-Slavery Medallion"}

# Evidence-card copy per artifact: what the object is and why it might matter for
# Darwin's defense. Placeholder drafts, easy to refine later.
var card_content = {
	"Plate": {
		"shows": "An ordinary household plate from Uncle Josiah's home.",
		"why": "It gives household context, but it does not directly prove abolitionist influence."
	},
	"Teapot": {
		"shows": "A teapot from the Wedgwood household.",
		"why": "It shows the domestic world Darwin entered, but by itself it is weak evidence."
	},
	"SermonNotes": {
		"shows": "Notes referencing the belief that all nations were made 'of one blood.'",
		"why": "This points to the idea that all humans belong to one family, not separate unequal races."
	},
	"Medallion": {
		"shows": "A medallion asking, 'Am I not a man and a brother?'",
		"why": "Josiah Wedgwood helped spread this abolitionist symbol, directly connecting Darwin's family to anti-slavery activism."
	}
}

onready var globals = get_node("/root/Globals")
onready var courtroom_prompt = get_node_or_null("/root/Level2/CanvasLayer/Control/CourtroomPrompt")
onready var evidence_card = get_node_or_null("/root/Level2/EvidenceCard")

# The artifact whose evidence card is currently open, held until the player
# presses Continue (then it is collected and the strength selection opens).
var _pending_item = null
var _pending_texture = null

# True once all Level 2 evidence is collected: the player may now press F to
# return to the courtroom.
var ready_for_courtroom = false

# True once the player has finished the opening Uncle Josiah conversation. The
# objective only shows the "search the house" progress once this is set.
var uncle_spoken = false

# Called when the node enters the scene tree for the first time.
func _ready():

	var back = get_node("/root/Level2/CanvasLayer/Control/Button")

	back.connect("pressed", self, "_Button_pressed")

	# The objective is progress-based: stage 1 asks the player to speak with Uncle
	# Josiah, then it becomes a "search the house" objective with an X/4 artifact
	# counter, and finally the return-to-court objective. _update_objective (called
	# here, after the Uncle conversation, and after each collected artifact) writes
	# the current text. scroll_active is disabled so the text never needs scrolling.
	var objective = get_node("/root/Level2/CanvasLayer/Control/Objective/Label")
	objective.scroll_active = false
	_update_objective()

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

	# The evidence card's Continue button hands off to strength selection.
	if evidence_card != null:
		evidence_card.connect("continued", self, "_on_card_continued")

	# Re-apply saved progress if the player has been here before (Back / level select).
	# On a fresh game there is no saved data, so this is a no-op.
	_restore_progress()


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

# Level 2: interacting with an artifact opens the parchment evidence card first.
# The artifact is NOT collected yet — that happens when the player presses
# Continue (see _on_card_continued), which then opens strength selection.
func show_evidence_card(item):
	if _pending_item != null:
		return
	if evidence_card == null:
		# No card available: fall back to collecting directly.
		collect_artifact(item)
		return
	_pending_item = item
	var art_name = item.name
	# Prefer the shrunk in-world object image; fall back to the card preview sprite.
	var tex = null
	var world_sprite = item.get_node_or_null("WorldSprite")
	if world_sprite != null and world_sprite.texture != null:
		tex = world_sprite.texture
	else:
		var preview = item.get_node_or_null("CanvasLayer/Control/" + art_name)
		if preview != null:
			tex = preview.texture
	_pending_texture = tex
	var shown_name = display_names[art_name] if display_names.has(art_name) else art_name
	var shows_text = ""
	var why_text = ""
	if card_content.has(art_name):
		shows_text = card_content[art_name]["shows"]
		why_text = card_content[art_name]["why"]
	evidence_card.show_card(shown_name, tex, shows_text, why_text)

# Continue pressed on the evidence card: collect the pending artifact into the
# Case File and open the Weak/Medium/Strong selection.
func _on_card_continued():
	var item = _pending_item
	_pending_item = null
	if item == null:
		return
	var art_name = item.name
	if collected.has(art_name):
		collected[art_name] = true
	item.queue_free()
	var case_file = get_node_or_null("/root/Level2/CaseFile")
	if case_file != null:
		var shown_name = display_names[art_name] if display_names.has(art_name) else art_name
		var desc = ""
		if card_content.has(art_name):
			desc = card_content[art_name]["shows"]
		case_file.open_label_mode(shown_name, _pending_texture, art_name, desc)
	else:
		_after_label()
	_pending_texture = null

# Runs once the player has labelled the freshly collected evidence.
func _on_evidence_labeled(evidence_name, strength):
	_after_label()

func _after_label():
	if all_evidence_collected():
		# Don't auto-return to the courtroom: let the player press F when ready.
		ready_for_courtroom = true
	# Refresh the objective's X/4 counter (or the final return-to-court text).
	_update_objective()
	# Persist the collection (Case File entry + collected flag) immediately.
	_save_progress()

# Called (from Dialog.gd) once the opening Uncle Josiah conversation finishes, so
# the objective can advance from "speak with Uncle Josiah" to the search stage.
func mark_uncle_spoken():
	if uncle_spoken:
		return
	uncle_spoken = true
	_update_objective()
	_save_progress()

# Writes the progress-based objective text into the top objective bar:
#  - before talking to Uncle Josiah: "Speak with Uncle Josiah."
#  - while searching:                "Search ... Artifacts collected: X/4."
#  - once all 4 are collected:       "All evidence collected. Press F to return to court."
func _update_objective():
	var panel = get_node_or_null("/root/Level2/CanvasLayer/Control/Objective")
	if panel == null:
		return
	var label = panel.get_node("Label")
	var text = ""
	var two_line = false
	if not uncle_spoken:
		text = "Objective: Speak with Uncle Josiah."
	elif all_evidence_collected():
		text = "Objective: All evidence collected. Press F to return to court."
	else:
		text = "Objective: Search Uncle Josiah's house for abolitionist evidence. Artifacts collected: " + str(_collected_count()) + "/4."
		two_line = true
	label.bbcode_text = "[center]" + text + "[/center]"
	# The search line is long enough to wrap to two lines; the others fit on one.
	panel.margin_bottom = 74.0 if two_line else 52.0

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

# Returns to the courtroom (same structure as Level 1): show the courtroom canvas
# and play the Level 2 opening dialogue, which then opens the Level 2 evidence
# selection UI.
func _enter_courtroom():
	ready_for_courtroom = false
	if courtroom_prompt != null:
		courtroom_prompt.visible = false
	# Now that the player has entered the courtroom, swap the exploration objective
	# for the courtroom objective. The exploration objective (set in _ready) stays
	# in place the whole time the player is inside Uncle Josiah's house.
	var objective_panel = get_node_or_null("/root/Level2/CanvasLayer/Control/Objective")
	if objective_panel != null:
		var objective = objective_panel.get_node("Label")
		objective.bbcode_text = "[center]Objective: Choose the strongest evidence to defend Darwin.[/center]"
		# This objective fits on one line, so restore the standard bar height.
		objective_panel.margin_bottom = 52.0
	get_node("/root/Level2/CanvasLayer/Courtroom").visible = true
	var dialog = get_node("/root/Level2/CanvasLayer/Control/Popup")
	# Level 2 courtroom opening dialogue; when it finishes, Dialog.gd opens the
	# Level 2 evidence-selection UI (mirrors Level 1's Level1Complete flow).
	dialog.launch_conversation("Level2Complete")

# --- Persistence (Back / level select preserve progress; only Start resets) ---

# Writes Level 2's current progress to the persistent global store: collected
# artifacts, whether Uncle Josiah has been spoken to, and the Case File entries.
func _save_progress():
	var cf = get_node_or_null("/root/Level2/CaseFile")
	var entries = []
	if cf != null:
		entries = cf.collected_evidence
	globals.save_level_progress("Level2", {
		"collected": collected,
		"uncle_spoken": uncle_spoken,
		"case_file": entries
	})

# Re-applies saved Level 2 progress on scene load: restores collected flags, the
# uncle_spoken flag and Case File entries, then rehydrates the world — collected
# artifacts are freed, and (if Uncle has been spoken to) the remaining artifacts are
# revealed with collision off, exactly as the Uncle dialogue does. Uncle's one-time
# intro/prompt is suppressed so it does not replay.
func _restore_progress():
	var data = globals.get_level_progress("Level2")
	if data == null:
		return
	if data.has("collected"):
		collected = data["collected"]
	uncle_spoken = data["uncle_spoken"] if data.has("uncle_spoken") else false
	var cf = get_node_or_null("/root/Level2/CaseFile")
	if cf != null and data.has("case_file"):
		cf.collected_evidence = data["case_file"]
	for id in ["Plate", "Teapot", "SermonNotes", "Medallion"]:
		var node = get_node_or_null("/root/Level2/" + id)
		if node == null:
			continue
		if collected.get(id, false):
			node.queue_free()
		elif uncle_spoken:
			node.visible = true
			var col = node.get_node_or_null("CollisionShape2D")
			if col != null:
				col.one_way_collision = false
	if uncle_spoken:
		var uncle = get_node_or_null("/root/Level2/Uncle")
		if uncle != null:
			uncle.intro_done = true
	ready_for_courtroom = all_evidence_collected()
	_update_objective()
