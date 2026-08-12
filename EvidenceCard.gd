extends CanvasLayer

# Level 2 "evidence card": shown when the player interacts with a household
# artifact, before the Weak/Medium/Strong selection. It reads like Robert Morris
# reviewing a piece of evidence — artifact name, image, what it shows, and why it
# might matter for Darwin's defense — then a Continue button hands off to the
# existing strength-selection step. Styled to match the Case File / dialogue UI
# (cream parchment, warm brown/gold borders). Built in code so it needs no
# hand-authored scene layout.
#
# Note: CanvasLayer has no `visible` property, so (like CaseFile/EvidenceSelect)
# everything lives under a root Control whose visibility we toggle.

signal continued

onready var globals = get_node("/root/Globals")

var root
var title_label
var image_rect
var strength_label
var shows_header
var shows_body
var why_header
var why_body
var continue_button

const TEXT = Color(0.25, 0.18, 0.1)
const TEXT_DARK = Color(0.12, 0.08, 0.04)
const BORDER = Color(0.541176, 0.388235, 0.227451)

func _ready():
	# Sit above the gameplay HUD / interaction prompt while open.
	layer = 5
	_build()
	root.visible = false

func _build():
	root = Control.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Dim the scene behind the card so it reads as a focused review moment.
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.35)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(dim)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.margin_left = -380.0
	panel.margin_right = 380.0
	panel.margin_top = -310.0
	panel.margin_bottom = 310.0
	panel.add_stylebox_override("panel", _panel_style())
	root.add_child(panel)

	# Content area: the title/image/text, occupying the panel ABOVE the button
	# strip. It is clipped so no artifact's text length can ever overlap or push
	# out the button — the same layout is used for every Level 2 artifact.
	var content = VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.margin_left = 40.0
	content.margin_top = 24.0
	content.margin_right = -40.0
	content.margin_bottom = -84.0
	content.rect_clip_content = true
	content.add_constant_override("separation", 10)
	panel.add_child(content)

	title_label = _label("", 28, true)
	title_label.align = Label.ALIGN_CENTER
	content.add_child(title_label)

	image_rect = TextureRect.new()
	image_rect.expand = true
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_rect.rect_min_size = Vector2(0, 140)
	image_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(image_rect)

	# Optional evidence-strength line (used by Level 1 cards; hidden for Level 2,
	# where the player still picks the strength after the card). Invisible children
	# take no space in a container, so Level 2's layout is unchanged.
	strength_label = _label("", 20, true)
	strength_label.align = Label.ALIGN_CENTER
	strength_label.visible = false
	content.add_child(strength_label)

	shows_header = _label("What it shows:", 21, true)
	content.add_child(shows_header)
	shows_body = _label("", 19, false)
	shows_body.autowrap = true
	content.add_child(shows_body)

	why_header = _label("Why it matters:", 21, true)
	content.add_child(why_header)
	why_body = _label("", 19, false)
	why_body.autowrap = true
	content.add_child(why_body)

	# Button pinned to the bottom-centre of the panel: always visible, in the same
	# place on every card, and independent of the text/image size above it.
	var button_bar = HBoxContainer.new()
	button_bar.anchor_top = 1.0
	button_bar.anchor_right = 1.0
	button_bar.anchor_bottom = 1.0
	button_bar.margin_left = 20.0
	button_bar.margin_right = -20.0
	button_bar.margin_top = -70.0
	button_bar.margin_bottom = -16.0
	button_bar.alignment = BoxContainer.ALIGN_CENTER
	panel.add_child(button_bar)

	continue_button = Button.new()
	continue_button.text = "Choose Artifact Strength"
	continue_button.rect_min_size = Vector2(340, 54)
	_style_button(continue_button)
	continue_button.connect("pressed", self, "_on_continue")
	button_bar.add_child(continue_button)

# Fills in and shows the card, blocking movement until the player continues.
func show_card(art_name, texture, shows_text, why_text, strength_text = "", wrap_title = false):
	title_label.text = "Artifact Found: " + art_name
	# Long titles can opt into wrapping onto two lines instead of overflowing off the
	# panel; defaults off, so cards with short titles render exactly as before.
	title_label.autowrap = wrap_title
	image_rect.texture = texture
	if strength_text != "":
		strength_label.text = strength_text
		strength_label.visible = true
	else:
		strength_label.visible = false
	# Show each section only when the level provides text for it. Levels 1 & 2 always
	# fill both; Level 3 has only the artifact description (no "why it matters" yet),
	# so its card omits that section cleanly instead of showing an empty header.
	var has_shows = shows_text != ""
	shows_header.visible = has_shows
	shows_body.visible = has_shows
	shows_body.text = shows_text
	var has_why = why_text != ""
	why_header.visible = has_why
	why_body.visible = has_why
	why_body.text = why_text
	root.visible = true
	globals.canMove = false
	continue_button.grab_focus()

func _on_continue():
	root.visible = false
	# Movement stays disabled: the strength-selection screen opens next.
	emit_signal("continued")

# --- parchment styling helpers (match Case File / dialogue UI) ---

func _font(size, bold):
	var f = DynamicFont.new()
	if bold:
		f.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	else:
		f.font_data = load("res://Assets/Fonts/Raleway-Regular.ttf")
	f.size = size
	return f

func _label(txt, size, bold):
	var l = Label.new()
	l.text = txt
	l.add_font_override("font", _font(size, bold))
	l.add_color_override("font_color", TEXT)
	return l

func _panel_style():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.949019, 0.886274, 0.745098, 0.98)
	sb.set_border_width_all(3)
	sb.border_color = BORDER
	sb.set_corner_radius_all(14)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 6
	return sb

func _card_style(bg):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(2)
	sb.border_color = BORDER
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _style_button(btn):
	btn.add_font_override("font", _font(20, true))
	btn.add_color_override("font_color", TEXT)
	btn.add_color_override("font_color_hover", TEXT_DARK)
	btn.add_color_override("font_color_pressed", TEXT_DARK)
	btn.add_color_override("font_color_focus", TEXT)
	btn.add_stylebox_override("normal", _card_style(Color(0.9, 0.83, 0.66, 0.95)))
	btn.add_stylebox_override("hover", _card_style(Color(0.98, 0.93, 0.79, 1.0)))
	btn.add_stylebox_override("pressed", _card_style(Color(0.84, 0.75, 0.57, 1.0)))
	btn.add_stylebox_override("focus", _card_style(Color(0.98, 0.93, 0.79, 1.0)))
