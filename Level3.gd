extends Node2D

# Level 3 now follows Level 1 & 2's structure: the player must collect every
# journal page (into the Case File) before returning to court. Collecting a page no
# longer presents it to the courtroom on its own — the page is simply gathered and
# the objective advances. Only once all pages are collected does the return-to-court
# prompt appear, and pressing F then plays Level 3's courtroom (victory) sequence.

# Evidence-card copy per artifact. Level 3 only has each page's existing journal
# text (from the item's own description), so that is shown as "What it shows"; the
# card omits "Why it matters" (Level 3 has no such field yet) and evidence strength
# (Level 3 does not rate pages). Placeholder drafts using existing Level 3 content.
var card_content = {
	"Page1": {
		"name": "Journal Page: Mollusca and Vertebrata",
		"shows": "I deduce from extreme difficulty of hypothesis of connecting mollusca and vertebrata, that there must be very great gaps."
	},
	"Page2": {
		"name": "Journal Page: Tapirs and Marsupials",
		"shows": "Tapirs existing in East Indian seas. Marsupial animals all show greater connection in quadrupeds, but plants do not follow by any means."
	},
	"Page3": {
		"name": "Journal Page: On Slavery and Equality",
		"shows": "A journal entry about a Black teacher who was the intellectual equal to his white colleagues - John Edmonstone - beside the note: \"Animals whom we have made our slaves, we do not like to consider our equals. Do not slaveholders wish to make the black man other kind?\""
	}
}

# Tracks which of Level 3's three journal pages have been collected. The required
# count is simply the number of pages in the level (Level 3 has no separate stored
# count), so it is derived from this dictionary's size.
var collected = {"Page1": false, "Page2": false, "Page3": false}

onready var globals = get_node("/root/Globals")
onready var evidence_card = get_node_or_null("/root/Level3/EvidenceCard")
onready var case_file = get_node_or_null("/root/Level3/CaseFile")
onready var courtroom_prompt = get_node_or_null("/root/Level3/CanvasLayer/Control/CourtroomPrompt")

# The page whose evidence card is currently open, held until the player presses
# Continue (then the strength-selection screen opens).
var _pending_item = null
var _pending_texture = null

# Node name of the page currently in the Weak/Medium/Strong selection screen. The
# page is only counted as collected once its strength has been chosen (see
# _on_evidence_labeled), so the counter and courtroom unlock wait for the choice.
var _labeling_name = ""

# True once every page is collected: the player may now press F to return to court.
var ready_for_courtroom = false

# True once the player has entered the courtroom, so F and the prompts stop after
# the courtroom (victory) sequence has begun.
var court_entered = false

# True once the opening Captain FitzRoy conversation has finished. The objective
# only advances from "Speak with Captain FitzRoy" to the explore/collect stage once
# this is set (from Dialog.gd, when the captain dialogue completes) — not merely
# when the player walks near him.
var has_spoken_to_fitzroy = false

# While OS.get_ticks_msec() is below this value, the early-entry warning is shown
# in the courtroom prompt because the player pressed F before collecting everything.
var _warning_until = 0

# Called when the node enters the scene tree for the first time.
func _ready():

	var back = get_node("/root/Level3/CanvasLayer/Control/Button")

	back.connect("pressed", self, "_Button_pressed")

	# The evidence card's Continue button opens strength selection (_on_card_continued);
	# choosing a strength then counts the page as collected (_on_evidence_labeled).
	if evidence_card != null:
		evidence_card.connect("continued", self, "_on_card_continued")
	if case_file != null:
		case_file.connect("evidence_labeled", self, "_on_evidence_labeled")

	# Level 3 has its own Case File (its own node instance, so a clean slate that
	# holds only Level 3 evidence). Show the "Press C" hint here too: this runs
	# after UI.gd's _ready (children ready before parent), overriding that script
	# hiding the hint outside Level 1.
	var hint = get_node_or_null("/root/Level3/CanvasLayer/Control/CaseFileHint")
	if hint != null:
		hint.visible = true

	# The return-to-court prompt stays hidden until all evidence is collected
	# (managed each frame in _process).
	if courtroom_prompt != null:
		courtroom_prompt.visible = false

	# Progress-based objective (mirrors Level 2): a search objective with an X/N
	# counter, then the return-to-court objective once everything is collected.
	var objective = get_node_or_null("/root/Level3/CanvasLayer/Control/Objective/Label")
	if objective != null:
		objective.scroll_active = false
	_update_objective()


#back button to main menu screen
func _Button_pressed():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

# Called by Item.gd when a Level 3 page is picked up. Shows the shared evidence
# card first; the page is collected once the player continues from the card (see
# _on_card_continued). The _pending_item guard prevents the same (or another) page
# being triggered while a card is already open.
func collect_artifact(item):
	if _pending_item != null:
		return
	_pending_item = item
	var art_name = item.name
	# Reuse the page's own image (the sprite shown in its world pickup preview).
	var tex = null
	var art_sprite = item.get_node_or_null("CanvasLayer/Control/" + art_name)
	if art_sprite != null:
		tex = art_sprite.texture
	_pending_texture = tex
	if evidence_card == null:
		# No card available: collect the page directly (keeps the old behaviour).
		_on_card_continued()
		return
	var content = card_content[art_name] if card_content.has(art_name) else {}
	var card_name = content["name"] if content.has("name") else art_name
	var shows_text = content["shows"] if content.has("shows") else ""
	# Level 3 has no "why it matters" text or evidence strength yet, so both are
	# omitted (the card hides those sections).
	evidence_card.show_card(card_name, tex, shows_text, "")

# Continue pressed on the evidence card: remove the page from the room and open the
# shared Weak/Medium/Strong selection screen (the same one Level 2 uses). The page
# is NOT counted as collected here — that happens once the player picks a strength
# (see _on_evidence_labeled), so the counter and courtroom unlock wait for the
# choice. This no longer presents the page to court; Level 3 is entered only after
# every page has been fully collected (see _unhandled_input / F).
func _on_card_continued():
	var item = _pending_item
	var tex = _pending_texture
	_pending_item = null
	_pending_texture = null
	if item == null:
		return
	var art_name = item.name
	# Remove the page from the room now so it cannot be collected twice.
	item.queue_free()
	if case_file != null:
		var content = card_content[art_name] if card_content.has(art_name) else {}
		var shown_name = content["name"] if content.has("name") else art_name
		var desc = content["shows"] if content.has("shows") else ""
		# Open the strength-selection screen. When the player chooses Weak/Medium/
		# Strong, CaseFile adds the entry with that strength and emits evidence_labeled.
		_labeling_name = art_name
		case_file.open_label_mode(shown_name, tex, art_name, desc)
	else:
		# No Case File available: count the page immediately so the level still
		# progresses (keeps the old fallback behaviour working).
		_mark_collected(art_name)

# Runs once the player has chosen a strength for the page just collected. Only now
# is the page counted, so the artifact counter and the "all evidence collected"
# unlock update strictly after the strength selection is confirmed.
func _on_evidence_labeled(evidence_name, strength):
	if _labeling_name == "":
		return
	var art_name = _labeling_name
	_labeling_name = ""
	_mark_collected(art_name)

# Marks a page collected exactly once, then unlocks the courtroom if that was the
# last page and refreshes the objective counter.
func _mark_collected(art_name):
	if collected.has(art_name):
		collected[art_name] = true
	if all_evidence_collected():
		ready_for_courtroom = true
	_update_objective()

# Drives the return-to-court prompt: the "ready" message once everything is
# collected, or a brief warning if the player pressed F too early. Both reuse the
# shared CourtroomPrompt panel (hidden during the Case File, dialogue, etc., via
# the globals.canMove gate).
func _process(delta):
	if courtroom_prompt == null or court_entered:
		if courtroom_prompt != null and court_entered:
			courtroom_prompt.visible = false
		return
	var label = courtroom_prompt.get_node_or_null("Label")
	if ready_for_courtroom and globals.canMove:
		courtroom_prompt.visible = true
		if label != null:
			label.bbcode_text = "[center]All evidence collected. Press F to return to court.[/center]"
	elif OS.get_ticks_msec() < _warning_until and globals.canMove:
		courtroom_prompt.visible = true
		if label != null:
			label.bbcode_text = "[center]You still need to collect all evidence before returning to court.[/center]"
	else:
		courtroom_prompt.visible = false

func _unhandled_input(event):
	# Ignore F while a card / dialogue / Case File is open, or after the courtroom
	# has already been entered.
	if not globals.canMove or court_entered:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_F:
		if ready_for_courtroom:
			_enter_courtroom()
		else:
			# Blocked: the player tried to return to court before collecting every
			# page. Show the warning message for a couple of seconds (see _process).
			_warning_until = OS.get_ticks_msec() + 2500

# Called (from Dialog.gd) once the opening Captain FitzRoy conversation finishes, so
# the objective can advance from "Speak with Captain FitzRoy" to the explore stage.
# Idempotent: talking to the Captain again (his repeat line) never resets progress.
func mark_fitzroy_spoken():
	if has_spoken_to_fitzroy:
		return
	has_spoken_to_fitzroy = true
	_update_objective()

# True only once every Level 3 page has been collected.
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

# Writes the progress-based objective text into the top objective bar:
#  - before the Captain conversation: "Speak with Captain FitzRoy."
#  - while exploring/collecting:       "Explore the Beagle ... Artifacts collected: X/3."
#  - once all are collected:           "All evidence collected. Press F to return to court."
func _update_objective():
	var objective_panel = get_node_or_null("/root/Level3/CanvasLayer/Control/Objective")
	if objective_panel == null:
		return
	var label = objective_panel.get_node("Label")
	var text = ""
	var two_line = false
	if not has_spoken_to_fitzroy:
		text = "Objective: Speak with Captain FitzRoy."
	elif all_evidence_collected():
		text = "Objective: All evidence collected. Press F to return to court."
	else:
		# The full line is long, so split it across two lines for readability.
		text = "Objective: Explore the Beagle to find evidence from Darwin's voyage.\nArtifacts collected: " + str(_collected_count()) + "/" + str(collected.size()) + "."
		two_line = true
	label.bbcode_text = "[center]" + text + "[/center]"
	# The explore line spans two lines; the others fit on one.
	objective_panel.margin_bottom = 74.0 if two_line else 52.0

# Enters the courtroom (only reachable once every page is collected). Plays Level 3's
# existing courtroom victory sequence (the Page3 conversation), which ends by
# revealing the next-level prompt. Dialogue and scoring are unchanged.
func _enter_courtroom():
	if court_entered:
		return
	court_entered = true
	ready_for_courtroom = false
	if courtroom_prompt != null:
		courtroom_prompt.visible = false
	var objective_panel = get_node_or_null("/root/Level3/CanvasLayer/Control/Objective")
	if objective_panel != null:
		var objective = objective_panel.get_node("Label")
		objective.bbcode_text = "[center]Objective: Present your evidence to the court.[/center]"
		objective_panel.margin_bottom = 52.0
	get_node("/root/Level3/CanvasLayer/Courtroom").visible = true
	var dialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
	dialog.launch_conversation("Page3")
