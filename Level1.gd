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

# Snapshot of artifact collected/visible state, used in _process to persist an
# unlock (professor reveal) even if the player leaves before collecting the artifact.
var _last_unlock_snapshot = ""

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
	# Re-apply saved progress if the player has been here before (Back / level select).
	# On a fresh game there is no saved data, so this is a no-op and Level 1 behaves
	# exactly as before.
	_restore_progress()
	_last_unlock_snapshot = _unlock_snapshot()

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
	# No fixed strength on the card: the player chooses Weak/Medium/Strong on the next
	# screen (consistent with Levels 2 & 3). The card's button leads into that screen.
	evidence_card.show_card(card_name, tex, shows_text, why_text, "")

# Continue pressed on the evidence card: mark the artifact collected, then open the
# Weak/Medium/Strong selection screen (same as Levels 2 & 3). Movement stays disabled
# until the player picks a strength (CaseFile.open_label_mode handles that).
func _on_card_continued():
	var item = _pending_item
	_pending_item = null
	if item == null:
		return
	var art_name = item.name
	if collected.has(art_name):
		collected[art_name] = true
	item.queue_free()
	var content = card_content[art_name] if card_content.has(art_name) else {}
	var desc = content["shows"] if content.has("shows") else ""
	var case_file = get_node_or_null("/root/Level1/CaseFile")
	if case_file != null:
		var shown_name = display_names[art_name] if display_names.has(art_name) else art_name
		# Open the strength-selection screen. When the player chooses, CaseFile adds the
		# entry with that strength and emits evidence_labeled -> _on_evidence_labeled.
		case_file.open_label_mode(shown_name, _pending_texture, art_name, desc)
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
	# Persist the collection (Case File entry + collected flag) immediately.
	_save_progress()

# Show the courtroom prompt only while the player is free to roam (hidden during
# the Case File, dialogue, etc.), and enter the courtroom when F is pressed.
func _process(delta):
	if courtroom_prompt != null:
		courtroom_prompt.visible = ready_for_courtroom and globals.canMove
	# An artifact becoming visible (professor unlock) or being freed (collected)
	# changes this snapshot; persist so leaving before collecting keeps the unlock.
	var snap = _unlock_snapshot()
	if snap != _last_unlock_snapshot:
		_last_unlock_snapshot = snap
		_save_progress()

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

# --- Persistence (Back / level select preserve progress; only Start resets) ---

# A small string capturing, per artifact, whether it is collected and (if it still
# exists) whether it is visible. Used only to detect changes cheaply in _process.
func _unlock_snapshot():
	var s = ""
	for id in ["Bone", "Rocks", "Portrait"]:
		var node = get_node_or_null("/root/Level1/" + id)
		var vis = node != null and node.visible
		s += id + ":" + str(collected.get(id, false)) + ":" + str(vis) + ";"
	return s

# Writes Level 1's current progress to the persistent global store: which artifacts
# are collected, which have been unlocked (professor-revealed), and the Case File
# entries. Derives "unlocked" from world state (a collected artifact was unlocked; an
# uncollected one is unlocked iff its node is currently visible).
func _save_progress():
	var unlocked = {}
	for id in ["Bone", "Rocks", "Portrait"]:
		if collected.get(id, false):
			unlocked[id] = true
		else:
			var node = get_node_or_null("/root/Level1/" + id)
			unlocked[id] = node != null and node.visible
	var cf = get_node_or_null("/root/Level1/CaseFile")
	var entries = []
	if cf != null:
		entries = cf.collected_evidence
	globals.save_level_progress("Level1", {
		"collected": collected,
		"unlocked": unlocked,
		"case_file": entries
	})

# Re-applies saved Level 1 progress on scene load: restores the collected flags and
# Case File entries, then rehydrates the world — collected artifacts are freed (so
# they can't be picked up again and their professor shows the "after" line), and
# unlocked-but-uncollected artifacts are shown with collision off (ready to pick up).
# Locked artifacts stay hidden so their professor still offers the question menu.
func _restore_progress():
	var data = globals.get_level_progress("Level1")
	if data == null:
		return
	if data.has("collected"):
		collected = data["collected"]
	var unlocked = data["unlocked"] if data.has("unlocked") else {}
	var cf = get_node_or_null("/root/Level1/CaseFile")
	if cf != null and data.has("case_file"):
		cf.collected_evidence = data["case_file"]
	for id in ["Bone", "Rocks", "Portrait"]:
		var node = get_node_or_null("/root/Level1/" + id)
		if node == null:
			continue
		if collected.get(id, false):
			node.queue_free()
		elif unlocked.get(id, false):
			node.visible = true
			var col = node.get_node_or_null("CollisionShape2D")
			if col != null:
				col.one_way_collision = false
	ready_for_courtroom = all_evidence_collected()
	if ready_for_courtroom:
		var objective = get_node("/root/Level1/CanvasLayer/Control/Objective/Label")
		objective.bbcode_text = "[center]Objective complete.[/center]"
	elif _collected_count() > 0:
		_update_progress()
