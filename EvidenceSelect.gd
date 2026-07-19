extends CanvasLayer

onready var globals = get_node("/root/Globals")
onready var root = $Root
onready var entries = $Root/EntriesContainer
onready var confirmation = $Root/Confirmation
onready var result = $Result
onready var result_title = $Result/Title
onready var result_score = $Result/Score
onready var result_body = $Result/Body
onready var result_conclusion = $Result/Conclusion
onready var continue_button = $Result/ContinueButton

# The artifact the player chose to present (stored for later courtroom steps).
var selected_evidence = ""

# Root path of whichever level instances this UI, so the same selection screen
# works in Level 1 and Level 2 without hardcoded node paths. In Level 1 this
# resolves to "/root/Level1", so Level 1 behaviour is unchanged.
func _scene_root():
	return "/root/" + get_tree().get_current_scene().get_name()

func _ready():
	root.visible = false
	result.visible = false
	# Style the result-screen continue button like a Case File card.
	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = 20
	continue_button.add_font_override("font", df)
	continue_button.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	continue_button.add_color_override("font_color_hover", Color(0.12, 0.08, 0.04))
	continue_button.add_color_override("font_color_pressed", Color(0.1, 0.07, 0.03))
	continue_button.add_stylebox_override("normal", _card_style(Color(0.9, 0.83, 0.66, 0.95)))
	continue_button.add_stylebox_override("hover", _card_style(Color(0.98, 0.93, 0.79, 1.0)))
	continue_button.add_stylebox_override("pressed", _card_style(Color(0.84, 0.75, 0.57, 1.0)))
	continue_button.add_stylebox_override("focus", _card_style(Color(0.98, 0.93, 0.79, 1.0)))
	continue_button.connect("pressed", self, "_on_continue_pressed")

# Opens the courtroom evidence-selection screen (styled like the Case File),
# listing the Level 1 evidence the player actually collected. Called after the
# courtroom opening dialogue finishes.
func open():
	selected_evidence = ""
	confirmation.text = ""
	_hide_courtroom_characters()
	_populate()
	# Dark overlay behind the parchment panel to calm the busy courtroom background.
	# Only shown in the Level 2 courtroom; Level 1's selection screen is unchanged.
	# It is a child of Root, so it hides automatically when the panel closes.
	var dim = root.get_node_or_null("Dim")
	if dim != null:
		dim.visible = get_tree().get_current_scene().get_name() == "Level2"
	root.visible = true
	globals.canMove = false

# Hides the courtroom character portraits so they don't peek around the evidence
# folder / result screen. They are re-shown per speaker when dialogue resumes.
func _hide_courtroom_characters():
	var court_node = get_node_or_null(_scene_root() + "/CanvasLayer/Courtroom")
	if court_node == null:
		return
	for n in ["Court", "Darwin", "Morris", "Prosecutor"]:
		var sprite = court_node.get_node_or_null(n)
		if sprite != null:
			sprite.visible = false

func _populate():
	for child in entries.get_children():
		entries.remove_child(child)
		child.queue_free()
	# Same collected-evidence data the Case File uses.
	var case_file = get_node_or_null(_scene_root() + "/CaseFile")
	var evidence = []
	if case_file != null:
		evidence = case_file.collected_evidence
	# Safe fallback if, somehow, no evidence was collected.
	if evidence.empty():
		entries.add_child(_make_label("No evidence available."))
		return
	for e in evidence:
		entries.add_child(_make_option(e))

# One selectable evidence entry: a real Button (artifact icon + name/strength),
# styled like a Case File card so it stays readable but is clearly clickable.
func _make_option(e):
	# Selection key stays the node name (Level 1's courtroom paths depend on it).
	var option_name = e["name"]
	if e.has("node_name") and e["node_name"] != "":
		option_name = e["node_name"]
	# Label: Level 2 shows the descriptive display name; Level 1 keeps its node name.
	var label_name = option_name
	if get_tree().get_current_scene().get_name() == "Level2":
		label_name = e["name"]
	var text = "  " + label_name
	if e.has("strength") and e["strength"] != "":
		text += "     -     " + e["strength"] + " evidence"

	var btn = Button.new()
	btn.text = text
	btn.align = Button.ALIGN_LEFT
	btn.rect_min_size = Vector2(0, 84)
	if e.has("texture") and e["texture"] != null:
		btn.icon = e["texture"]
		btn.expand_icon = true

	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = 22
	btn.add_font_override("font", df)
	btn.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	btn.add_color_override("font_color_hover", Color(0.12, 0.08, 0.04))
	btn.add_color_override("font_color_pressed", Color(0.1, 0.07, 0.03))
	btn.add_stylebox_override("normal", _card_style(Color(0.9, 0.83, 0.66, 0.92)))
	btn.add_stylebox_override("hover", _card_style(Color(0.98, 0.93, 0.79, 0.98)))
	btn.add_stylebox_override("pressed", _card_style(Color(0.84, 0.75, 0.57, 1.0)))
	btn.add_stylebox_override("focus", _card_style(Color(0.98, 0.93, 0.79, 0.98)))

	btn.connect("pressed", self, "_on_evidence_selected", [option_name])
	return btn

func _card_style(bg):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(2)
	sb.border_color = Color(0.541176, 0.388235, 0.227451)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

func _make_label(txt):
	var lbl = Label.new()
	lbl.text = txt
	lbl.align = Label.ALIGN_CENTER
	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = 22
	lbl.add_font_override("font", df)
	lbl.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	return lbl

# Stores the chosen artifact and shows a confirmation. Rocks and Bone are the
# weak-evidence paths wired so far: each hides this UI and plays its courtroom
# argument. Portrait still just confirms the selection (its path isn't built yet).
func _on_evidence_selected(option_name):
	selected_evidence = option_name
	confirmation.text = "Selected Evidence: " + option_name
	print("Evidence selected for the defense: ", option_name)
	if option_name == "Rocks" or option_name == "Bone" or option_name == "Portrait" or option_name == "Plate" or option_name == "Teapot" or option_name == "SermonNotes" or option_name == "Medallion":
		# Hide the selection UI and play the matching courtroom dialogue (Rocks/Bone/
		# Portrait are Level 1; Plate and Teapot are Level 2 weak paths; the Sermon
		# Notes and Medallion are the Level 2 strong paths). When it finishes,
		# Dialog.gd calls show_result() (below).
		root.visible = false
		var dialog = get_node_or_null(_scene_root() + "/CanvasLayer/Control/Popup")
		if dialog != null:
			dialog.launch_conversation(option_name + "Courtroom")

# Shows the result screen after a courtroom argument. Called from Dialog.gd once
# the dialogue finishes. Rocks/Bone use the weak layout; Portrait uses the strong
# layout (same nodes/style, just different text and a taller body to fit).
func show_result():
	if selected_evidence == "Portrait" or selected_evidence == "SermonNotes" or selected_evidence == "Medallion":
		_set_result_strong()
	else:
		_set_result_weak()
	_hide_courtroom_characters()
	root.visible = false
	result.visible = true
	globals.canMove = false

# Weak-evidence result (Rocks and Bone). Uses the approved weak-screen layout.
func _set_result_weak():
	result_title.text = "Courtroom Result: Weak Evidence"
	result_score.text = "Defense: 0\nProsecution: 1"
	result_conclusion.text = "The prosecution wins this round."
	if selected_evidence == "Bone":
		result_body.text = "The court is not convinced.\nThe bone shows Darwin's scientific education, but it does not prove that he opposed racism or slavery."
	elif selected_evidence == "Plate":
		result_body.text = "The court is not convinced.\nThe regular plate shows household context, but it does not prove Darwin's abolitionist influence or his rejection of racism."
	elif selected_evidence == "Teapot":
		result_body.text = "The court is not convinced.\nThe teapot shows household context, but it does not prove Darwin's abolitionist influence or his rejection of racism."
	else:
		result_body.text = "The court is not convinced.\nThe rocks show Darwin's scientific education, but they do not prove that he opposed racism or slavery."
	_place(result_title, -205, -160)
	_place(result_score, -120, -50)
	_place(result_body, -10, 110)
	_place(result_conclusion, 130, 175)

# Strong-evidence result (Portrait). Same nodes/style, but the body is longer, so
# the sections are spaced to fit it inside the folder without scrolling.
func _set_result_strong():
	result_title.text = "Courtroom Result: Strong Evidence"
	result_score.text = "Defense: 1\nProsecution: 0"
	if selected_evidence == "SermonNotes":
		result_body.text = "The court is persuaded.\nThe \"One Blood\" sermon notes show that Darwin was surrounded by the belief that all humans share one common origin.\n\nThat belief challenged the idea that different races were separate kinds of human beings."
	elif selected_evidence == "Medallion":
		result_body.text = "The court is persuaded.\nThe anti-slavery medallion showed an enslaved man kneeling in chains with the words, \"Am I not a man and a brother?\"\n\nIt connected Darwin's family to abolitionist activism and to the belief that all human beings share dignity and worth."
	else:
		result_body.text = "The court is persuaded.\nThe portrait connects Darwin to John Edmonstone, a formerly enslaved teacher who opposed slavery.\n\nIt also points to Darwin's abolitionist background, including Josiah Wedgwood's anti-slavery medallion and the belief that all nations were made \"of one blood.\""
	result_conclusion.text = "The defense wins this round."
	_place(result_title, -224, -182)
	_place(result_score, -164, -100)
	_place(result_body, -88, 126)
	_place(result_conclusion, 142, 182)

# Sets a Result section's vertical extent (nodes are center-anchored, so these
# are offsets from the folder center; horizontal margins stay as authored).
func _place(node, top, bottom):
	node.margin_top = top
	node.margin_bottom = bottom

# Continue to the next stage of the investigation. Level 1 -> Level 2 (unchanged);
# the Level 2 courtroom continues on to Level 3.
func _on_continue_pressed():
	if get_tree().get_current_scene().get_name() == "Level2":
		get_tree().change_scene("res://Level3.tscn")
	else:
		get_tree().change_scene("res://Level2.tscn")
