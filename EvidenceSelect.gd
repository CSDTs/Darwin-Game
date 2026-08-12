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

# Final game outcome screen (victory / defeat / narrow victory), built in code and
# shown only after the Level 3 courtroom result. Matches the parchment Case File look.
var final_root
var final_title
var final_main
var final_body
var final_score_label
var final_button
# Victory-only flourishes: the "CASE WON" stamp image + a set of gold sparkle nodes
# that twinkle/pulse/drift while the victory screen is up (animated in _process).
# Hidden / inactive for the defeat and draw outcomes.
var final_stamp
var final_sparkles = []
var _sparkle_phase = []
var _sparkle_freq = []
var _sparkle_base_y = []
# True only while the victory outcome is shown; gates the sparkle animation.
var _victory_active = false

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
	_build_final_screen()

# Opens the courtroom evidence-selection screen (styled like the Case File),
# listing the Level 1 evidence the player actually collected. Called after the
# courtroom opening dialogue finishes.
func open():
	selected_evidence = ""
	confirmation.text = ""
	_hide_courtroom_characters()
	_populate()
	# Dark overlay behind the parchment panel to calm the busy courtroom background.
	# Shown in the Level 2 and Level 3 courtrooms; Level 1's selection screen is
	# unchanged. It is a child of Root, so it hides automatically when the panel closes.
	var dim = root.get_node_or_null("Dim")
	if dim != null:
		var sn = get_tree().get_current_scene().get_name()
		dim.visible = sn == "Level2" or sn == "Level3"
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

# One selectable evidence entry: a clickable card with a fixed-size artifact image +
# name/strength, styled like a Case File card.
func _make_option(e):
	# Selection key stays the node name (Level 1's courtroom paths depend on it).
	var option_name = e["name"]
	if e.has("node_name") and e["node_name"] != "":
		option_name = e["node_name"]
	# Label: Levels 2 & 3 show the descriptive display name; Level 1 keeps its node name.
	var sn = get_tree().get_current_scene().get_name()
	var label_name = option_name
	if sn == "Level2" or sn == "Level3":
		label_name = e["name"]
	var strength_text = ""
	if e.has("strength") and e["strength"] != "":
		strength_text = e["strength"] + " evidence"

	# The clickable, styled card background (the image/text are laid out over it).
	var btn = Button.new()
	btn.rect_min_size = Vector2(0, 84)
	btn.add_stylebox_override("normal", _card_style(Color(0.9, 0.83, 0.66, 0.92)))
	btn.add_stylebox_override("hover", _card_style(Color(0.98, 0.93, 0.79, 0.98)))
	btn.add_stylebox_override("pressed", _card_style(Color(0.84, 0.75, 0.57, 1.0)))
	btn.add_stylebox_override("focus", _card_style(Color(0.98, 0.93, 0.79, 0.98)))
	btn.connect("pressed", self, "_on_evidence_selected", [option_name])

	if sn == "Level3":
		_fill_level3_option(btn, e, label_name, strength_text)
	else:
		_fill_default_option(btn, e, label_name, strength_text)
	return btn

# Level 3 rows: an explicit anchored layout (NOT an HBoxContainer). The autowrapping
# name label previously collapsed the whole HBox to nothing (blank rows); anchoring the
# three parts directly to the button avoids that container feedback entirely. Fixed
# image on the left, name filling the middle (wraps if long, slightly smaller font),
# strength in a fixed right-hand column so a long name never runs into it. All parts use
# mouse_filter IGNORE so clicks still reach the button.
func _fill_level3_option(btn, e, label_name, strength_text):
	var img = TextureRect.new()
	img.anchor_top = 0.5
	img.anchor_bottom = 0.5
	img.margin_left = 16.0
	img.margin_right = 106.0
	img.margin_top = -32.0
	img.margin_bottom = 32.0
	img.expand = true
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if e.has("texture") and e["texture"] != null:
		img.texture = e["texture"]
	btn.add_child(img)

	var str_lbl = _opt_label(strength_text, 20)
	str_lbl.anchor_left = 1.0
	str_lbl.anchor_right = 1.0
	str_lbl.anchor_bottom = 1.0
	str_lbl.margin_left = -190.0
	str_lbl.margin_right = -22.0
	str_lbl.align = Label.ALIGN_RIGHT
	btn.add_child(str_lbl)

	# Name in the middle column, left-aligned, at a slightly smaller size so the longest
	# journal-page title fits on one line. NOT autowrap: an autowrapping Label whose
	# width is anchor-driven renders blank in Godot 3.x (that is what emptied the names).
	var name_lbl = _opt_label(label_name, 18)
	name_lbl.anchor_right = 1.0
	name_lbl.anchor_bottom = 1.0
	name_lbl.margin_left = 118.0
	name_lbl.margin_right = -200.0
	btn.add_child(name_lbl)

# Level 1 & 2 rows (unchanged): a fixed image + single name/strength label in an HBox.
func _fill_default_option(btn, e, label_name, strength_text):
	var hbox = HBoxContainer.new()
	hbox.anchor_right = 1.0
	hbox.anchor_bottom = 1.0
	hbox.margin_left = 14
	hbox.margin_right = -14
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_constant_override("separation", 16)
	btn.add_child(hbox)

	var img = TextureRect.new()
	img.rect_min_size = Vector2(90, 64)
	img.expand = true
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if e.has("texture") and e["texture"] != null:
		img.texture = e["texture"]
	hbox.add_child(img)

	var text = label_name
	if strength_text != "":
		text += "     -     " + strength_text
	var lbl = _opt_label(text, 22)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

# A dark-on-parchment, vertically-centered label used inside an evidence option row.
func _opt_label(txt, size):
	var lbl = Label.new()
	lbl.text = txt
	lbl.valign = Label.VALIGN_CENTER
	lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = size
	lbl.add_font_override("font", df)
	lbl.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	return lbl

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
	# Rocks/Bone/Portrait are Level 1; Plate/Teapot/SermonNotes/Medallion are Level 2;
	# Page1/Page2/Page3 are Level 3. Each hides this UI and plays its matching
	# "<name>Courtroom" argument (scene-aware Popup path). When it finishes, Dialog.gd
	# calls show_result() (below), which picks the result from the stored selection.
	if option_name == "Rocks" or option_name == "Bone" or option_name == "Portrait" or option_name == "Plate" or option_name == "Teapot" or option_name == "SermonNotes" or option_name == "Medallion" or option_name == "Page1" or option_name == "Page2" or option_name == "Page3":
		root.visible = false
		var dialog = get_node_or_null(_scene_root() + "/CanvasLayer/Control/Popup")
		if dialog != null:
			dialog.launch_conversation(option_name + "Courtroom")

# Shows the result screen after a courtroom argument. Called from Dialog.gd once
# the dialogue finishes. Rocks/Bone use the weak layout; Portrait uses the strong
# layout (same nodes/style, just different text and a taller body to fit).
func show_result():
	# The result is chosen from the artifact identity (Page3 / Portrait / SermonNotes /
	# Medallion are strong; everything else is weak), NOT the strength the player rated
	# it — so a mis-rated Level 3 page still gets its intended courtroom result.
	var is_strong = selected_evidence == "Portrait" or selected_evidence == "SermonNotes" or selected_evidence == "Medallion" or selected_evidence == "Page3"
	# Add this round to the cumulative trial score (once per level), then show the
	# running total for the whole game — not just this round's single point.
	globals.apply_courtroom_result(get_tree().get_current_scene().get_name(), is_strong)
	if is_strong:
		_set_result_strong()
	else:
		_set_result_weak()
	result_score.text = "Defense: " + str(globals.defense_score) + "\nProsecution: " + str(globals.prosecution_score)
	_hide_courtroom_characters()
	root.visible = false
	result.visible = true
	globals.canMove = false

# Weak-evidence result (Rocks and Bone). Uses the approved weak-screen layout.
func _set_result_weak():
	result_title.text = "Courtroom Result: Weak Evidence"
	# result_score text (the cumulative Defense/Prosecution total) is set in show_result.
	result_conclusion.text = "The prosecution wins this round."
	if selected_evidence == "Bone":
		result_body.text = "The court is not convinced.\nThe bone shows Darwin's scientific education, but it does not prove that he opposed racism or slavery."
	elif selected_evidence == "Plate":
		result_body.text = "The court is not convinced.\nThe regular plate shows household context, but it does not prove Darwin's abolitionist influence or his rejection of racism."
	elif selected_evidence == "Teapot":
		result_body.text = "The court is not convinced.\nThe teapot shows household context, but it does not prove Darwin's abolitionist influence or his rejection of racism."
	elif selected_evidence == "Page1":
		result_body.text = "The court is not convinced.\nThe journal page on mollusks and vertebrates shows Darwin's scientific thinking, but it does not directly prove his rejection of racism or racial separation."
	elif selected_evidence == "Page2":
		result_body.text = "The court is not convinced.\nThe journal page on tapirs and marsupials shows Darwin's scientific observations, but it does not directly prove his opposition to racism or racial separation."
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
	# result_score text (the cumulative Defense/Prosecution total) is set in show_result.
	if selected_evidence == "SermonNotes":
		result_body.text = "The court is persuaded.\nThe \"One Blood\" sermon notes show that Darwin was surrounded by the belief that all humans share one common origin.\n\nThat belief challenged the idea that different races were separate kinds of human beings."
	elif selected_evidence == "Medallion":
		result_body.text = "The court is persuaded.\nThe anti-slavery medallion showed an enslaved man kneeling in chains with the words, \"Am I not a man and a brother?\"\n\nIt connected Darwin's family to abolitionist activism and to the belief that all human beings share dignity and worth."
	elif selected_evidence == "Page3":
		result_body.text = "The court is persuaded.\nDarwin's journal entry shows that he understood how slaveholders used racist biology to treat Black people as a separate or lesser kind of human.\n\nBy rejecting that separation and connecting humanity through shared origin, Darwin challenged racial hierarchy."
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
# the Level 2 courtroom continues on to Level 3. Level 3 is the final stage, so
# instead of leaving directly it shows the final victory/loss outcome screen.
func _on_continue_pressed():
	var sn = get_tree().get_current_scene().get_name()
	if sn == "Level2":
		get_tree().change_scene("res://Level3.tscn")
	elif sn == "Level3":
		# The Level 3 courtroom result has just been shown and its point already
		# applied, so the cumulative score is final. Show the outcome screen (its own
		# button returns to the menu). No score is changed or reset here.
		_show_final_outcome()
	else:
		get_tree().change_scene("res://Level2.tscn")

# --- Final game outcome screen (shown only after the Level 3 result) ---

# Builds the (initially hidden) final outcome screen: a dimmed parchment panel with a
# title, main line, body, the final cumulative score, and a Return to Main Menu button.
func _build_final_screen():
	final_root = Control.new()
	final_root.anchor_right = 1.0
	final_root.anchor_bottom = 1.0
	final_root.visible = false
	add_child(final_root)

	var dim = ColorRect.new()
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0, 0, 0, 0.6)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	final_root.add_child(dim)

	var bg = TextureRect.new()
	bg.texture = load("res://Assets/Objects/case_file.png")
	bg.expand = true
	bg.stretch_mode = 6
	_anchor_center(bg, 860, -300, 600)
	final_root.add_child(bg)

	# Gold sparkle nodes placed around the title, corners and edges of the parchment
	# (kept clear of the body paragraph, score and button). Added before the text so
	# they sit behind it and peek around the letters. They are animated (twinkle +
	# scale pulse + gentle drift) in _process and only made visible for the victory
	# outcome. A small soft gold dot is generated in code (no imported image).
	var dot = _make_dot_texture(28, Color(1, 0.95, 0.65))
	# Positions concentrated on the left/top/bottom and the far-right edges, kept clear of
	# the body/score/button text AND of the stamp in the bottom-right corner.
	var offsets = [
		Vector2(-300, -215), Vector2(-150, -235), Vector2(0, -245), Vector2(150, -235), Vector2(300, -215),
		Vector2(-80, -200), Vector2(120, -195), Vector2(-220, -185), Vector2(230, -180),
		Vector2(-370, -140), Vector2(-410, -40), Vector2(-420, 60), Vector2(-390, 150), Vector2(-350, 235),
		Vector2(-350, -90), Vector2(-320, 20), Vector2(-300, 110),
		Vector2(370, -150), Vector2(405, -120), Vector2(420, -30), Vector2(-120, 285),
		Vector2(-260, 275), Vector2(60, 285), Vector2(150, 288),
		Vector2(-200, -165), Vector2(200, -165), Vector2(-30, -200), Vector2(-120, -220),
		Vector2(-420, 10), Vector2(420, -90), Vector2(-280, 180), Vector2(30, -240)
	]
	for off in offsets:
		var sp = TextureRect.new()
		sp.texture = dot
		sp.expand = true
		sp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sz = 20 + randi() % 14
		sp.rect_size = Vector2(sz, sz)
		sp.rect_pivot_offset = Vector2(sz / 2.0, sz / 2.0)
		# final_root fills the 1280x720 viewport from (0,0); the parchment is centred,
		# so screen centre (640,360) + the offset places each sparkle on the parchment.
		sp.rect_position = Vector2(640, 360) + off - Vector2(sz / 2.0, sz / 2.0)
		sp.modulate = Color(1, 1, 1, 0)
		final_root.add_child(sp)
		final_sparkles.append(sp)
		_sparkle_phase.append(randf() * TAU)
		_sparkle_freq.append(2.0 + randf() * 2.0)
		_sparkle_base_y.append(sp.rect_position.y)

	# All content is nudged up ~30px vs the original so the larger bottom-right stamp
	# has room below the text.
	final_title = _final_label(34, true)
	_anchor_center(final_title, 700, -205, 60)
	final_root.add_child(final_title)

	final_main = _final_label(24, true)
	final_main.autowrap = true
	_anchor_center(final_main, 600, -130, 44)
	final_root.add_child(final_main)

	final_body = _final_label(19, true)
	final_body.autowrap = true
	_anchor_center(final_body, 620, -75, 165)
	final_root.add_child(final_body)

	final_score_label = _final_label(22, true)
	_anchor_center(final_score_label, 620, 100, 40)
	final_root.add_child(final_score_label)

	final_button = Button.new()
	final_button.text = "Return to Main Menu"
	_anchor_center(final_button, 360, 165, 56)
	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = 20
	final_button.add_font_override("font", df)
	final_button.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	final_button.add_color_override("font_color_hover", Color(0.12, 0.08, 0.04))
	final_button.add_color_override("font_color_pressed", Color(0.1, 0.07, 0.03))
	final_button.add_stylebox_override("normal", _card_style(Color(0.9, 0.83, 0.66, 0.95)))
	final_button.add_stylebox_override("hover", _card_style(Color(0.98, 0.93, 0.79, 1.0)))
	final_button.add_stylebox_override("pressed", _card_style(Color(0.84, 0.75, 0.57, 1.0)))
	final_button.add_stylebox_override("focus", _card_style(Color(0.98, 0.93, 0.79, 1.0)))
	final_button.connect("pressed", self, "_on_final_return")
	final_root.add_child(final_button)

	# "CASE WON" stamp: the imported PNG (transparent, distressed red circular stamp),
	# placed in the lower-right of the parchment and rotated ~-12 degrees so it reads as
	# stamped on. Sized ~160px so it feels celebratory while sitting clear of the title,
	# main line, score, and Return button (it only overlaps empty parchment / the far
	# right of the body). Shown only for the victory outcome.
	final_stamp = TextureRect.new()
	final_stamp.expand = true
	final_stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	final_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	final_stamp.anchor_left = 0.5
	final_stamp.anchor_top = 0.5
	final_stamp.anchor_right = 0.5
	final_stamp.anchor_bottom = 0.5
	# ~205px stamp in the BOTTOM-RIGHT corner. Centred at offset (305, 170) from the panel
	# centre, its inscribed circle sits BELOW the (now raised) body paragraph, to the
	# RIGHT of the score text and the Return button, and inside the parchment border — so
	# it does not overlap any text.
	final_stamp.margin_left = 203.0
	final_stamp.margin_top = 68.0
	final_stamp.margin_right = 408.0
	final_stamp.margin_bottom = 273.0
	final_stamp.rect_pivot_offset = Vector2(102, 102)
	final_stamp.rect_rotation = -12.0
	var stamp_path = "res://Assets/Objects/Case_stamp.png"
	if ResourceLoader.exists(stamp_path):
		final_stamp.texture = load(stamp_path)
	final_stamp.visible = false
	final_root.add_child(final_stamp)

# Determines and shows the outcome from the CUMULATIVE score (Defense vs Prosecution),
# which already includes the Level 3 result. Reads the score only — never changes or
# resets it. A tie is treated as a narrow defense victory (no separate tie screen).
func _show_final_outcome():
	var d = globals.defense_score
	var p = globals.prosecution_score
	var victory = d > p
	if victory:
		# Stronger, gold, celebratory headline (Ron wants the exclamation mark).
		final_title.text = "Victory for the Defense!"
		final_title.add_font_override("font", _bold_font(40))
		final_title.add_color_override("font_color", Color(0.72, 0.52, 0.12))
		final_main.text = "The defense has won the case."
		final_body.text = "Across the investigation, the evidence showed that Darwin was shaped by abolitionist ideas, rejected slavery, and challenged racist claims that humanity was divided into separate kinds."
	elif d < p:
		# Loss screen: unchanged plain title (same font/colour as before).
		final_title.text = "Defeat"
		final_title.add_font_override("font", _bold_font(34))
		final_title.add_color_override("font_color", Color(0.2, 0.14, 0.08))
		final_main.text = "The prosecution has won the case."
		final_body.text = "The defense failed to present enough strong evidence to show how Darwin's life, influences, and writings challenged slavery and racial separation."
	else:
		# With 3 levels (one point each) the total is always 3, so a real playthrough is
		# never tied. This branch only occurs if the player jumps straight to Level 3 via
		# level select after playing exactly one earlier level (a 1-1 score). Show a draw.
		final_title.text = "Draw"
		final_title.add_font_override("font", _bold_font(34))
		final_title.add_color_override("font_color", Color(0.2, 0.14, 0.08))
		final_main.text = "The case ends in a divided verdict."
		final_body.text = "The defense presented meaningful evidence, but not enough to fully overcome the prosecution's argument."
	final_score_label.text = "Final Score: Defense " + str(d) + " — Prosecution " + str(p)
	# Victory-only flourishes: the CASE WON stamp and the animated sparkles (hidden /
	# inactive otherwise). _victory_active gates the sparkle animation in _process.
	final_stamp.visible = victory
	_victory_active = victory
	for sp in final_sparkles:
		sp.visible = victory
		if not victory:
			sp.modulate = Color(1, 1, 1, 0)
	result.visible = false
	root.visible = false
	final_root.visible = true
	globals.canMove = false

# Animates the victory sparkles while the victory screen is up: each twinkles (alpha
# via a per-node sine), gently pulses scale, and drifts slowly upward, staggered by a
# random phase/frequency. Cheap no-op (one bool check) in every other case.
func _process(delta):
	if not _victory_active:
		return
	var t = OS.get_ticks_msec() / 1000.0
	for i in range(final_sparkles.size()):
		var sp = final_sparkles[i]
		var tw = 0.5 + 0.5 * sin(t * _sparkle_freq[i] + _sparkle_phase[i])
		# Even stronger: high alpha floor (0.6) so they stay bright, and a large scale
		# pulse so the twinkle is very noticeable.
		sp.modulate = Color(1, 1, 1, lerp(0.6, 1.0, tw))
		var sc = 0.9 + 1.1 * tw
		sp.rect_scale = Vector2(sc, sc)
		var yy = sp.rect_position.y - 8.0 * delta
		if yy < _sparkle_base_y[i] - 30.0:
			yy = _sparkle_base_y[i]
		sp.rect_position.y = yy

# Return to Main Menu. Navigation only — progress is NOT reset here (only the Start
# button on the home screen resets, per the existing navigation rules).
func _on_final_return():
	get_tree().change_scene("res://Main Menu/Main_Menu.tscn")

# Anchors a control to the folder centre with a fixed width/height and a vertical
# offset from centre (top), so the outcome screen lines up over the parchment.
func _anchor_center(node, w, top, h):
	node.anchor_left = 0.5
	node.anchor_top = 0.5
	node.anchor_right = 0.5
	node.anchor_bottom = 0.5
	node.margin_left = -w / 2.0
	node.margin_right = w / 2.0
	node.margin_top = top
	node.margin_bottom = top + h

# A centered dark-on-parchment label for the outcome screen.
func _final_label(size, bold):
	var l = Label.new()
	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = size
	l.add_font_override("font", df)
	l.add_color_override("font_color", Color(0.2, 0.14, 0.08))
	l.align = Label.ALIGN_CENTER
	l.valign = Label.VALIGN_CENTER
	return l

# A bold DynamicFont of the given size (used by the victory title and the stamp).
func _bold_font(size):
	var f = DynamicFont.new()
	f.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	f.size = size
	return f

# Generates a small soft round dot texture in code (no imported image) for the sparkle
# particles. Radial alpha falloff, tinted with the given colour.
func _make_dot_texture(size, col):
	var img = Image.new()
	img.create(size, size, false, Image.FORMAT_RGBA8)
	img.lock()
	var c = size / 2.0
	for y in range(size):
		for x in range(size):
			var dist = Vector2(x - c + 0.5, y - c + 0.5).length() / c
			var a = clamp(1.0 - dist, 0.0, 1.0)
			a = a * a
			img.set_pixel(x, y, Color(col.r, col.g, col.b, a))
	img.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex
