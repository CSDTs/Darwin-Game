extends CanvasLayer

# Emitted after the player labels a freshly collected artifact, so the level can
# continue its collection flow (progress / completion).
signal evidence_labeled(evidence_name, strength)

onready var globals = get_node("/root/Globals")
onready var root = $Root
onready var label_mode = $Root/LabelMode
onready var list_mode = $Root/ListMode
onready var artifact_name_label = $Root/LabelMode/ArtifactName
onready var artifact_image = $Root/LabelMode/ArtifactImage
onready var entries_container = $Root/ListMode/EntriesContainer

# Evidence kept for as long as the player stays in the level. Each entry is
# { "name": String, "strength": String, "texture": Texture, "node_name": String }.
var collected_evidence = []
var pending_name = ""
var pending_texture = null
var pending_node_name = ""
# Optional short description (used by Level 2's evidence card; empty elsewhere).
var pending_description = ""
var is_label_mode = false

func _ready():
	root.visible = false
	$Root/LabelMode/Weak.connect("pressed", self, "_on_strength_selected", ["Weak"])
	$Root/LabelMode/Medium.connect("pressed", self, "_on_strength_selected", ["Medium"])
	$Root/LabelMode/Strong.connect("pressed", self, "_on_strength_selected", ["Strong"])

# Opens the Case File so the player can rate a just-collected artifact.
# texture is the artifact's own image, reused from the world item.
func open_label_mode(evidence_name, texture = null, node_name = "", description = ""):
	pending_name = evidence_name
	pending_texture = texture
	pending_node_name = node_name if node_name != "" else evidence_name
	pending_description = description
	is_label_mode = true
	artifact_name_label.text = evidence_name
	artifact_image.texture = texture
	label_mode.visible = true
	list_mode.visible = false
	root.visible = true
	globals.canMove = false

# Adds a fully-labelled evidence entry directly, without showing the
# Weak/Medium/Strong prompt. Used by Level 1's collection card, which presents a
# fixed strength. Emits evidence_labeled so the level's collection flow continues.
func add_evidence(evidence_name, texture, node_name, strength, description = ""):
	var key = node_name if node_name != "" else evidence_name
	collected_evidence.append({"name": evidence_name, "strength": strength, "texture": texture, "node_name": key, "description": description})
	emit_signal("evidence_labeled", evidence_name, strength)

func _on_strength_selected(strength):
	collected_evidence.append({"name": pending_name, "strength": strength, "texture": pending_texture, "node_name": pending_node_name, "description": pending_description})
	var labeled_name = pending_name
	pending_name = ""
	pending_texture = null
	pending_node_name = ""
	pending_description = ""
	is_label_mode = false
	root.visible = false
	globals.canMove = true
	emit_signal("evidence_labeled", labeled_name, strength)

# Manual open/close with the C key. Checks the raw key directly so it does not
# depend on a project Input Map action.
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_C:
		if is_label_mode:
			return
		if root.visible:
			_close()
		elif globals.canMove:
			_open_list_mode()

func _open_list_mode():
	_populate_list()
	label_mode.visible = false
	list_mode.visible = true
	root.visible = true
	globals.canMove = false

func _close():
	root.visible = false
	globals.canMove = true

# Rebuilds the review list: one image + name + strength card per collected item.
func _populate_list():
	for child in entries_container.get_children():
		entries_container.remove_child(child)
		child.queue_free()
	if collected_evidence.empty():
		entries_container.add_child(_make_label("No evidence collected yet."))
		return
	for e in collected_evidence:
		var row = HBoxContainer.new()
		row.add_constant_override("separation", 14)
		var image = TextureRect.new()
		image.texture = e["texture"]
		image.expand = true
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# Compact image so up to 4 entries (image + name/strength + description) fit
		# the parchment without overlapping "Press C to close"; aspect is preserved.
		image.rect_min_size = Vector2(90, 64)
		row.add_child(image)
		# Levels 1 & 2 label each entry with a rated strength; Level 3 has no strength
		# for its journal pages, so the name is shown on its own (no dangling "- ").
		var strength_suffix = ""
		if e.has("strength") and e["strength"] != "":
			strength_suffix = "  -  " + e["strength"] + " evidence"
		var lbl = _make_label(e["name"] + strength_suffix)
		lbl.valign = Label.VALIGN_CENTER
		lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if e.has("description") and e["description"] != "":
			# Level 2 entries include a short description under the name/strength.
			var text_box = VBoxContainer.new()
			text_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
			text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			text_box.add_constant_override("separation", 2)
			text_box.add_child(lbl)
			var desc = _make_label(e["description"], 15)
			desc.autowrap = true
			desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			text_box.add_child(desc)
			row.add_child(text_box)
		else:
			row.add_child(lbl)
		entries_container.add_child(row)

# Builds a dark-on-parchment readable label.
func _make_label(txt, size = 22):
	var lbl = Label.new()
	lbl.text = txt
	var df = DynamicFont.new()
	df.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	df.size = size
	lbl.add_font_override("font", df)
	lbl.add_color_override("font_color", Color(0.25, 0.18, 0.1))
	return lbl
