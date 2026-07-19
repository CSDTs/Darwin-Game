extends StaticBody2D

onready var dialog = get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Control/Popup")
onready var courtroom =  get_node("/root/"+ get_tree().get_current_scene().get_name()+ "/CanvasLayer/Courtroom")
onready var globals = get_node("/root/Globals")

# True while the player is inside this artifact's interaction area.
var player_near = false

# True for Level 2 household artifacts, which are shown as the real object in the
# room (see _ready) instead of the shared glowing pickup box. Drives the subtle
# proximity highlight in _process.
var is_natural_item = false

# Base (rest) scale of the magnifying-glass marker, captured in _ready. The pulse
# in _process only ever multiplies this by <= 1.0, so the marker never grows past
# its rest size (40% of the artifact) and never drifts.
var marker_base_scale = 0.0

# Warm, slightly muted tint so Level 2 artifacts sit in the house's warm indoor
# lighting instead of reading as bright, high-contrast pasted-on stickers. A gentle
# brighten is applied only while the player is near (the proximity highlight).
const L2_BASE_TINT = Color(0.9, 0.85, 0.77, 0.97)
const L2_NEAR_TINT = Color(1.08, 1.02, 0.93, 1.0)

# Per-artifact tints; default to the shared tints above, but the teapot overrides
# them (see _ready) so it seats into the room better. Read every frame by _process.
var l2_base_tint = L2_BASE_TINT
var l2_near_tint = L2_NEAR_TINT

func _ready():
	#When the item is ready, turn on the one way collision (so the player can walk through it)
	$CollisionShape2D.one_way_collision = true
	$Area2D.connect("body_entered", self, "_on_interaction_area_entered")
	$Area2D.connect("body_exited", self, "_on_interaction_area_exited")
	if self.name == "Bone":
		$CanvasLayer/Control/Bone.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Anatomy Specimen: a bone from Professor Monro's lecture collection.[/center]"
	elif self.name == "Rocks":
		$CanvasLayer/Control/Rocks.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Plinian Society Note: This note shows Darwin's early exposure to natural history discussion and evidence-based scientific debate. It is not direct evidence of Darwin's abolitionist views, but it helps show that his later ideas grew from observation, evidence, and scientific argument rather than racial ideology.[/center]"
	elif self.name == "Portrait":
		$CanvasLayer/Control/Portrait.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Abolitionist Keepsake: a portrait commissioned by John Edmonstone to mark his friendship with Darwin.[/center]"
	elif self.name == "Plate":
		$CanvasLayer/Control/Plate.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It appears to be a plate.[/center]"
	elif self.name == "Teapot":
		$CanvasLayer/Control/Teapot.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]It is a teapot..[/center]"
	elif self.name == "Medallion":
		$CanvasLayer/Control/Medallion.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]This is the medallion.[/center]"
	elif self.name == "SermonNotes":
		$CanvasLayer/Control/SermonNotes.visible = true
		# Use the new sermon-notes art once it is added to the project (accepting
		# either filename); fall back to the existing page art if it is not present.
		for sermon_path in ["res://Assets/Objects/sermon_notes.png", "res://Assets/Objects/sermon_notes_transparent.png"]:
			if ResourceLoader.exists(sermon_path):
				$CanvasLayer/Control/SermonNotes.texture = load(sermon_path)
				break
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]\"One Blood\" Sermon Notes: a record of the sermon that the Universal Father \"hath made of one blood all nations\" - a reminder that all people belong to one human family.[/center]"
	elif self.name == "Page1":
		$CanvasLayer/Control/Page1.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]I deduce from extreme difficulty of hypothesis of connecting mollusca and vertebrata, that there must be very great gaps.[/center]"
	elif self.name == "Page2":
		$CanvasLayer/Control/Page2.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Tapirs existing in East Indian seas. Marsupial animals all show greater connection in quadrupeds, but plants do not follow by any means.[/center]"
	elif self.name == "Page3":
		$CanvasLayer/Control/Page3.visible = true
		$CanvasLayer/Control/RichTextLabel.bbcode_text = "[center]Here is a journal entry about a Black teacher who was the intellectual equal to his white colleagues. That must be John Edmonstone. And next to i another quote: \"Animals whom we have made our slaves, we do not like to consider our equals. Do not slaveholders wish to make the black man other kind?\"[/center]"
	
	# --- Level 2 natural presentation ---
	# Level 2 artifacts are real household objects placed around Uncle Josiah's
	# house, not glowing pickup boxes. Hide the shared glow animation and show the
	# object itself, sized down to a small on-surface footprint with a soft contact
	# shadow so it reads as resting on the furniture. _process adds a subtle
	# highlight when the player is close. The interaction Area2D is left untouched,
	# so shrinking the visible sprite does not make pickups harder.
	# Target on-surface widths (world px), sized to match objects already painted
	# into the map (kitchen dishes, table papers, a small coin-sized medallion).
	var l2_target_width = {"Plate": 44.0, "Teapot": 48.0, "Medallion": 38.0, "SermonNotes": 46.0}
	if l2_target_width.has(self.name):
		is_natural_item = true
		$AnimatedSprite.visible = false
		# Keep the visible sprite small, but give interaction a small-to-medium
		# (invisible) proximity zone and relabel the prompt. Interaction is driven by
		# proximity (see _process), so the player can inspect from the nearby table
		# edge without standing on the object, but not from across the room.
		# Circle radius is 379.8 * scale * root_scale(2): 0.11 -> ~84 world units
		# (down from ~114). Level 1 & 3 items keep their original Area2D and prompt.
		$Area2D.scale = Vector2(0.11, 0.11)
		$InteractionPrompt.set_prompt("", "Press Space to inspect evidence")

		# Per-artifact tone + contact shadow. Defaults suit most objects; the teapot
		# reads as pasted-on, so it gets a darker/warmer tone and a stronger, wider
		# shadow to seat it on the table.
		l2_base_tint = L2_BASE_TINT
		l2_near_tint = L2_NEAR_TINT
		var shadow_alpha = 0.16
		var shadow_squash = 0.42
		var shadow_widen = 1.0
		if self.name == "Teapot":
			l2_base_tint = Color(0.8, 0.76, 0.7, 1.0)
			l2_near_tint = Color(0.94, 0.89, 0.81, 1.0)
			shadow_alpha = 0.24
			shadow_squash = 0.5
			shadow_widen = 1.08

		var preview = get_node_or_null("CanvasLayer/Control/" + self.name)
		if preview != null and preview.texture != null:
			var tex = preview.texture
			$WorldSprite.texture = tex
			# Size the object to about l2_target_width world px wide regardless of the
			# source image size. self.scale is the item's root scale (2).
			var s = l2_target_width[self.name] / max(1.0, tex.get_width() * self.scale.x)
			$WorldSprite.scale = Vector2(s, s)
			# Warm/soften the sprite so it matches the painted map instead of reading
			# as a bright, high-contrast sticker (see _process for the near-highlight).
			$WorldSprite.modulate = l2_base_tint
			# Soft contact shadow: the same silhouette, darkened, squashed flat and
			# nudged down so the object looks grounded on the surface, not floating.
			$Shadow.texture = tex
			$Shadow.scale = Vector2(s * shadow_widen, s * shadow_squash)
			$Shadow.position = Vector2(1, 3)
			$Shadow.modulate = Color(0, 0, 0, shadow_alpha)
			$Shadow.visible = true
		$WorldSprite.visible = true
		# Small "inspectable evidence" magnifying-glass marker placed just above and
		# to the side of the artifact (never covering it). It is a plain Sprite (no
		# collision) and a child of this item, so it hides automatically when the
		# artifact is collected/freed. Only shown once the asset exists in the
		# project. Sized to a small ~22 world px width regardless of source size.
		var mag_path = "res://Assets/Objects/magnifying_glass.png"
		if ResourceLoader.exists(mag_path):
			var mag = load(mag_path)
			$Marker.texture = mag
			# Size and place the marker PROPORTIONALLY to this artifact, so it always
			# reads as a small tag pinned to the object's top-right corner instead of
			# a fixed icon floating far away:
			#   - width ~46% of the artifact (a helper, still clearly smaller),
			#   - offset up-and-right by a fraction of the artifact width,
			#   - slightly transparent so the artifact stays the primary object.
			# Positions are item-local; self.scale.x is the item root scale (2), so a
			# local offset p renders at 2*p world units from the artifact centre.
			var art_w = l2_target_width[self.name]
			var mark_w = art_w * 0.46
			var ms = mark_w / max(1.0, mag.get_width() * self.scale.x)
			marker_base_scale = ms
			$Marker.scale = Vector2(ms, ms)
			$Marker.position = Vector2(art_w * 0.26, -art_w * 0.26)
			$Marker.modulate = Color(1, 1, 1, 0.85)
			$Marker.visible = true

func _process(delta):
	# Show the interaction prompt ("Press Space...") while the player is near and the
	# artifact is revealed. The prompt hides itself during dialogue / card / Case File.
	$InteractionPrompt.set_showing(player_near and visible)

	# Proximity highlight + soft yellow "glow" breathing for Level 2 household
	# artifacts (in place of the shared glowing pickup box). The artifact rests at
	# its muted base tint (warmer while the player is near) and gently breathes a
	# warm brightening in and out — an additive lift weighted toward red/green (and
	# little blue) so it reads as a soft yellow glow on the object rather than a
	# plain white sheen. Same highlight language as the magnifying glass, but milder
	# (brightness only — no opacity/scale change, no ring or halo), so the object
	# softly stands out while staying part of the room.
	if is_natural_item:
		var art_pulse = 0.5 + 0.5 * sin(OS.get_ticks_msec() / 1000.0 * 3.0)
		var lift = 0.4 * art_pulse
		var base_tint = l2_near_tint if (player_near and visible and globals.canMove) else l2_base_tint
		$WorldSprite.modulate = Color(base_tint.r + lift, base_tint.g + lift * 0.85, base_tint.b + lift * 0.28, base_tint.a)
		# Gentle pulse on the magnifying-glass marker so it's easier to notice: a
		# soft opacity breath (70% -> 100%) plus a very small scale breath
		# (92% -> 100% of its rest size, so it never gets larger than the artifact).
		# Scaling is around the sprite's own centre, so it doesn't drift.
		if $Marker.visible and marker_base_scale > 0.0:
			var pulse = 0.5 + 0.5 * sin(OS.get_ticks_msec() / 1000.0 * 3.0)
			# Stronger, but still gentle, glow: a higher opacity floor (82% -> 100%)
			# plus a soft brighten at the peak (up to +15%) so the marker reads as a
			# subtle glow rather than a flat icon. Scale breathes 92% -> 100% of rest.
			var glow = lerp(1.0, 1.15, pulse)
			$Marker.modulate = Color(glow, glow, glow, lerp(0.82, 1.0, pulse))
			var msc = marker_base_scale * lerp(0.92, 1.0, pulse)
			$Marker.scale = Vector2(msc, msc)
		# Interact from anywhere inside the enlarged proximity area (not only when
		# the raycast happens to hit the small object), so pickups are forgiving.
		if player_near and visible and globals.canMove and Input.is_action_just_pressed("interact"):
			setItemControlLayer(true)

#Called when the player interacts with the artifact (Space). Opens the artifact
#card immediately — the old "T to take / D to drop" screen has been removed.
func setItemControlLayer(status):
	# Interacting with an artifact goes straight to the level's artifact card. No
	# take/drop screen and no T/D presses are involved any more:
	#   - Level 2 household items open the parchment evidence card (show_evidence_card),
	#   - Level 1 & 3 artifacts hand off to the level's collect_artifact, which shows
	#     the card and then the Weak/Medium/Strong selection before the Case File.
	# Both only start while the player is free to act, so a rapid second interact
	# press (movement is disabled the moment the card opens) can't collect twice.
	if status == true:
		var scene = get_tree().get_current_scene()
		if is_natural_item and scene.has_method("show_evidence_card"):
			if globals.canMove:
				globals.canMove = false
				scene.show_evidence_card(self)
			return
		if scene.has_method("collect_artifact"):
			if globals.canMove:
				globals.canMove = false
				scene.collect_artifact(self)
			return
	# Legacy fallback (no card-based level): the old take/drop control layer. No
	# shipped level uses this path — every level implements collect_artifact.
	$CanvasLayer/Control.visible = status
	if status == true:
		globals.canMove = false
	
#Gets the state of the control layer
func getItemControlLayer():
	return $CanvasLayer/Control.visible

func _on_interaction_area_entered(body):
	if body.name == "Lawyer":
		player_near = true

func _on_interaction_area_exited(body):
	if body.name == "Lawyer":
		player_near = false
