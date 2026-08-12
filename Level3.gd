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
		# Long title -> wrap it cleanly on the card (opt-in; other cards unaffected).
		"wrap_title": true,
		"shows": "Darwin noticed that connecting very different groups of animals, like mollusks and vertebrates, was difficult because the fossil record had large gaps.",
		"why": "This shows Darwin thinking about common ancestry and missing evidence. Even when the connections were hard to see, he believed life could still be connected through deep history rather than separate creation."
	},
	"Page2": {
		"name": "Journal Page: Tapirs and Marsupials",
		"wrap_title": true,
		"shows": "Darwin compared animals from different regions and noticed patterns in how certain groups, such as tapirs and marsupials, were distributed across the world.",
		"why": "This shows Darwin using geography and animal relationships to question old ideas about life. These observations helped him think about shared origins and connections between living things."
	},
	"Page3": {
		"name": "Darwin Journal Entry",
		# Internal/canonical answer: this is the winning "Strong" evidence in the
		# courtroom. It is deliberately NOT shown on the card and does NOT skip the
		# strength screen — the player still has to judge the strength themselves. Kept
		# separate from the player's chosen strength (stored in the Case File).
		"intended_strength": "Strong",
		# The quote is the evidence itself (shown under "What it shows"); "why" is the
		# interpretation; "desc" is the concise line used in the Case File list.
		"shows": "\"Animals whom we have made our slaves we do not like to consider our equals.— Do not slave holders wish to make the black man other kind\"",
		"why": "Darwin saw that slaveholders needed an excuse for treating Black people as less than human. By arguing that all humans shared a common origin, Darwin challenged racist claims that different races were separate kinds of people.",
		"desc": "Darwin questioned the racist idea that Black people were a separate or lesser kind of human being."
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

# True once the player has entered the courtroom, so the return step / prompts stop
# after the courtroom (victory) sequence has begun.
var court_entered = false

# True once the opening Captain FitzRoy conversation has finished. The objective
# only advances from "Speak with Captain FitzRoy" to the explore/collect stage once
# this is set (from Dialog.gd, when the captain dialogue completes) — not merely
# when the player walks near him.
var has_spoken_to_fitzroy = false

# True once the SECOND Captain FitzRoy conversation (after all evidence is collected)
# has finished. That conversation is what sends the player to the courtroom — there is
# no longer an F-to-court shortcut. Set from Dialog.gd via mark_fitzroy_return().
var fitzroy_return_done = false

# The choice screen shown after the second Captain conversation (Observe Finches /
# Return to Court), built in code in _build_choice_ui(). _choice_made guards against
# double selection if the player clicks quickly.
var _choice_layer
var _choice_root
var _choice_made = false

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

	# Build the (hidden) Observe Finches / Return to Court choice screen.
	_build_choice_ui()

	# Re-apply saved progress if the player has been here before (Back / level select).
	# On a fresh game there is no saved data, so this is a no-op.
	_restore_progress()


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
	var why_text = content["why"] if content.has("why") else ""
	var wrap_title = content.has("wrap_title") and content["wrap_title"]
	# Show the card's "why it matters" for pages that define it, but never an evidence
	# strength — the player must judge the strength themselves on the next screen (the
	# intended/winning strength is internal only). Pages without "why" omit that
	# section (the card hides empty sections). Long journal-page titles opt into wrapping.
	evidence_card.show_card(card_name, tex, shows_text, why_text, "", wrap_title)

# Continue pressed on the evidence card: remove the page from the room and open the
# shared Weak/Medium/Strong selection screen (the same one Level 2 uses) so the player
# judges the strength themselves — including the winning Darwin Journal Entry, whose
# "Strong" rating is internal only. The page is counted only once the Case File reports
# the chosen strength (evidence_labeled -> _on_evidence_labeled), so the counter and
# courtroom unlock wait for that. This no longer presents the page to court; Level 3 is
# entered only after every page has been fully collected (see _unhandled_input / F).
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
	if case_file == null:
		# No Case File available: count the page immediately so the level still
		# progresses (keeps the old fallback behaviour working).
		_mark_collected(art_name)
		return
	var content = card_content[art_name] if card_content.has(art_name) else {}
	var shown_name = content["name"] if content.has("name") else art_name
	# Case File description: a concise line so the list stays readable; falls back to
	# the "shows" text for pages without a dedicated description.
	var desc = content["desc"] if content.has("desc") else (content["shows"] if content.has("shows") else "")
	# Open the strength-selection screen. When the player chooses Weak/Medium/Strong,
	# CaseFile adds the entry with that strength and emits evidence_labeled.
	_labeling_name = art_name
	case_file.open_label_mode(shown_name, tex, art_name, desc)

# Runs once the player has chosen a strength for the page just collected. Only now
# is the page counted, so the artifact counter and the "all evidence collected"
# unlock update strictly after the strength selection is confirmed.
func _on_evidence_labeled(evidence_name, strength):
	if _labeling_name == "":
		return
	var art_name = _labeling_name
	_labeling_name = ""
	_mark_collected(art_name)

# Marks a page collected exactly once, then refreshes the objective (which switches
# to "Return to Captain FitzRoy" once the last page is collected). There is no longer
# an F-to-court shortcut — the player must talk to the Captain again to go to court.
func _mark_collected(art_name):
	if collected.has(art_name):
		collected[art_name] = true
	_update_objective()
	# Persist the collection (Case File entry + collected flag) immediately.
	_save_progress()

# Called (from Dialog.gd) once the opening Captain FitzRoy conversation finishes, so
# the objective can advance from "Speak with Captain FitzRoy" to the explore stage.
# Idempotent: talking to the Captain again never resets progress.
func mark_fitzroy_spoken():
	if has_spoken_to_fitzroy:
		return
	has_spoken_to_fitzroy = true
	_update_objective()
	_save_progress()

# Called (from Dialog.gd) once the SECOND Captain FitzRoy conversation finishes (the
# "return with the evidence" line, available only after all 3 pages are collected).
# This is what now transitions the player into the Level 3 courtroom. Deferred so the
# courtroom conversation launches after the current dialogue fully unwinds.
func mark_fitzroy_return():
	if fitzroy_return_done:
		return
	fitzroy_return_done = true
	_save_progress()
	call_deferred("_enter_courtroom")

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
#  - before the first Captain conversation: "Speak with Captain FitzRoy."
#  - while exploring/collecting:            "Explore the Beagle ... Artifacts collected: X/3."
#  - once all are collected:                "Return to Captain FitzRoy with the evidence."
#  - after the second Captain conversation: "Present your evidence to the court."
func _update_objective():
	var objective_panel = get_node_or_null("/root/Level3/CanvasLayer/Control/Objective")
	if objective_panel == null:
		return
	var label = objective_panel.get_node("Label")
	var text = ""
	var two_line = false
	if not has_spoken_to_fitzroy:
		text = "Objective: Speak with Captain FitzRoy."
	elif not all_evidence_collected():
		# The full line is long, so split it across two lines for readability.
		text = "Objective: Explore the Beagle to find evidence from Darwin's voyage.\nArtifacts collected: " + str(_collected_count()) + "/" + str(collected.size()) + "."
		two_line = true
	elif not fitzroy_return_done:
		text = "Objective: Return to Captain FitzRoy with the evidence."
	else:
		text = "Objective: Present your evidence to the court."
	label.bbcode_text = "[center]" + text + "[/center]"
	# The explore line spans two lines; the others fit on one.
	objective_panel.margin_bottom = 74.0 if two_line else 52.0

# Enters the courtroom (only reachable once every page is collected). Plays the Level
# 3 courtroom opening dialogue; when it finishes, Dialog.gd opens the Level 3 evidence
# selection UI (mirrors Level 1's Level1Complete / Level 2's Level2Complete flow).
func _enter_courtroom():
	if court_entered:
		return
	court_entered = true
	if courtroom_prompt != null:
		courtroom_prompt.visible = false
	var objective_panel = get_node_or_null("/root/Level3/CanvasLayer/Control/Objective")
	if objective_panel != null:
		var objective = objective_panel.get_node("Label")
		objective.bbcode_text = "[center]Objective: Present your evidence to the court.[/center]"
		objective_panel.margin_bottom = 52.0
	get_node("/root/Level3/CanvasLayer/Courtroom").visible = true
	var dialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
	dialog.launch_conversation("Level3Complete")

# --- Persistence (Back / level select preserve progress; only Start resets) ---

# Writes Level 3's current progress to the persistent global store: collected pages,
# whether Captain FitzRoy has been spoken to, and the Case File entries.
func _save_progress():
	var cf = get_node_or_null("/root/Level3/CaseFile")
	var entries = []
	if cf != null:
		entries = cf.collected_evidence
	globals.save_level_progress("Level3", {
		"collected": collected,
		"fitzroy_spoken": has_spoken_to_fitzroy,
		"fitzroy_return_done": fitzroy_return_done,
		"case_file": entries
	})

# Re-applies saved Level 3 progress on scene load: restores collected flags, the
# Captain-spoken flag and Case File entries, then rehydrates the world — collected
# pages are freed, and (if the Captain has been spoken to) the remaining pages have
# their collision cleared, exactly as the Captain dialogue does (the pages are already
# visible in the scene). The Captain's one-time intro/prompt is suppressed.
func _restore_progress():
	var data = globals.get_level_progress("Level3")
	if data == null:
		return
	if data.has("collected"):
		collected = data["collected"]
	has_spoken_to_fitzroy = data["fitzroy_spoken"] if data.has("fitzroy_spoken") else false
	fitzroy_return_done = data["fitzroy_return_done"] if data.has("fitzroy_return_done") else false
	var cf = get_node_or_null("/root/Level3/CaseFile")
	if cf != null and data.has("case_file"):
		cf.collected_evidence = data["case_file"]
	for id in ["Page1", "Page2", "Page3"]:
		var node = get_node_or_null("/root/Level3/" + id)
		if node == null:
			continue
		if collected.get(id, false):
			node.queue_free()
		elif has_spoken_to_fitzroy:
			var col = node.get_node_or_null("CollisionShape2D")
			if col != null:
				col.one_way_collision = false
	if has_spoken_to_fitzroy:
		var captain = get_node_or_null("/root/Level3/Captain")
		if captain != null:
			captain.intro_done = true
	_update_objective()
	# Edge case: the player already finished the second Captain conversation and left
	# mid-court (via Back, or by continuing from the Finch Minigame). Resume the
	# courtroom on return so they are not stuck.
	if fitzroy_return_done:
		call_deferred("_enter_courtroom")

# --- Second Captain conversation choice screen (Observe Finches / Return to Court) ---

# Builds the (initially hidden) choice panel in code: a dimmed parchment panel with a
# prompt and two buttons.
func _build_choice_ui():
	_choice_layer = CanvasLayer.new()
	_choice_layer.layer = 6
	add_child(_choice_layer)
	_choice_root = Control.new()
	_choice_root.anchor_right = 1.0
	_choice_root.anchor_bottom = 1.0
	_choice_root.visible = false
	_choice_layer.add_child(_choice_root)

	var dim = ColorRect.new()
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0, 0, 0, 0.5)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_choice_root.add_child(dim)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.margin_left = -320.0
	panel.margin_top = -140.0
	panel.margin_right = 320.0
	panel.margin_bottom = 140.0
	panel.add_stylebox_override("panel", _choice_style(Color(0.949019, 0.886274, 0.745098, 0.98), 3))
	_choice_root.add_child(panel)

	var prompt = _choice_label("Where would you like to go?", 26)
	prompt.anchor_right = 1.0
	prompt.margin_left = 24.0
	prompt.margin_top = 34.0
	prompt.margin_right = -24.0
	prompt.margin_bottom = 104.0
	prompt.align = Label.ALIGN_CENTER
	prompt.valign = Label.VALIGN_CENTER
	panel.add_child(prompt)

	var finch_btn = _choice_button("Observe Finches")
	finch_btn.anchor_right = 0.0
	finch_btn.margin_left = 40.0
	finch_btn.margin_top = 160.0
	finch_btn.margin_right = 310.0
	finch_btn.margin_bottom = 228.0
	finch_btn.connect("pressed", self, "_on_choice_finches")
	panel.add_child(finch_btn)

	var court_btn = _choice_button("Return to Court")
	court_btn.anchor_right = 0.0
	court_btn.margin_left = 330.0
	court_btn.margin_top = 160.0
	court_btn.margin_right = 600.0
	court_btn.margin_bottom = 228.0
	court_btn.connect("pressed", self, "_on_choice_court")
	panel.add_child(court_btn)

# Shows the choice screen after the second Captain conversation. Movement stays paused
# (globals.canMove is false), so the Case File cannot be opened over it either.
func show_fitzroy_choice():
	_choice_made = false
	_choice_root.visible = true
	globals.canMove = false

# "Observe Finches": play FitzRoy's short line, then head to the Finch Minigame.
func _on_choice_finches():
	if _choice_made:
		return
	_choice_made = true
	_choice_root.visible = false
	var dialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
	dialog.launch_conversation("FinchChoiceYes")

# "Return to Court": play FitzRoy's short line, then enter the Level 3 courtroom.
func _on_choice_court():
	if _choice_made:
		return
	_choice_made = true
	_choice_root.visible = false
	var dialog = get_node("/root/Level3/CanvasLayer/Control/Popup")
	dialog.launch_conversation("FinchChoiceNo")

# Called (from Dialog.gd) after "Very well. Make it brief." Marks the return
# conversation done (so returning from the minigame resumes the courtroom) and loads
# the existing Finch Minigame scene. Progress is saved, never reset.
func go_to_finch_minigame():
	fitzroy_return_done = true
	_save_progress()
	var finch_path = "res://FinchMinigame.tscn"
	if ResourceLoader.exists(finch_path):
		get_tree().change_scene(finch_path)
	else:
		# Safety: don't crash if the minigame scene is missing — go to court instead.
		push_warning("FinchMinigame.tscn not found; entering the courtroom instead.")
		call_deferred("_enter_courtroom")

# --- Parchment styling helpers for the choice screen ---

func _choice_style(bg, border):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(border)
	sb.border_color = Color(0.541176, 0.388235, 0.227451)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _choice_label(txt, size):
	var l = Label.new()
	l.text = txt
	var f = DynamicFont.new()
	f.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	f.size = size
	l.add_font_override("font", f)
	l.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	return l

func _choice_button(txt):
	var btn = Button.new()
	btn.text = txt
	var f = DynamicFont.new()
	f.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	f.size = 22
	btn.add_font_override("font", f)
	btn.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	btn.add_color_override("font_color_hover", Color(0.12, 0.08, 0.04))
	btn.add_color_override("font_color_pressed", Color(0.1, 0.07, 0.03))
	btn.add_stylebox_override("normal", _choice_style(Color(0.9, 0.83, 0.66, 0.95), 2))
	btn.add_stylebox_override("hover", _choice_style(Color(0.98, 0.93, 0.79, 1.0), 2))
	btn.add_stylebox_override("pressed", _choice_style(Color(0.84, 0.75, 0.57, 1.0), 2))
	btn.add_stylebox_override("focus", _choice_style(Color(0.98, 0.93, 0.79, 1.0), 2))
	return btn
