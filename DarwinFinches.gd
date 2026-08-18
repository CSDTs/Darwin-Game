extends Node2D

# Darwin's Finches — a Godot conversion of the CSnap "DarwinFinches" minigame (assets
# extracted to res://Assets/Finches/). It is reached from Level 3: after the player
# collects all 3 artifacts and returns to Captain FitzRoy, choosing "Observe Finches"
# loads this scene (Level3.go_to_finch_minigame). When the minigame finishes, pressing
# Space returns to res://Level3.tscn, whose saved progress auto-resumes the courtroom.
# The scene is otherwise self-contained (it does not touch Globals or the case scoring),
# so it can also be run on its own with F6 for testing.
#
# Flow (matches the CSnap project):
#   1. Intro: Darwin explains the task.
#   2. Collect: the 4 finches (cactus / ground / vegetarian / warbler) each fly in on
#      their own island background; Darwin narrates what each one eats; the net follows
#      the mouse and clicking a finch while the net is over it "catches" it (it flies to
#      the collection box). Once all 4 are caught ->
#   3. Inspect: Darwin says it's time to inspect the beaks.
#   4. Match: on the table, drag the 4 beak tools onto the matching finch drop-zone
#      (the same tool->target mapping as the original). All 4 matched -> done.
#
# The Snap stage is 480x360 (origin centre, y-up). It is drawn 2x, centred in the
# 1280x720 window (so it is letterboxed left/right). s2g() converts Snap -> Godot px.

const DIR = "res://Assets/Finches/"
const DISPLAY = 2.0            # stage scale (480x360 -> 960x720)
const OX = 160.0              # left offset to centre the 960-wide stage in 1280px

# Extracted costume files (see Assets/Finches/manifest.tsv).
const TEX = {
	"table": "00_table.png", "galapagos": "01_galapagos_desert.png",
	"veg_stage": "02_vegetarian_stage.png", "ground_stage": "03_ground_stage.png",
	"cactus_stage": "04_cactus_stage.png", "net": "05_net.png",
	"darwin": "14_speaking_darwin.png", "box": "15_box2.png",
	"wirecutter": "16_wirecutter_pliers.png", "tweezers": "17_TWEEZER.png",
	"pliers": "18_gripping_pliers.png", "needlenose": "19_needlenose_pliers.png",
	"fly": "20_fly.png", "cactus_bud": "22_Cactus_bud.png", "berries": "23_berries.png",
	"seed": "29_seed.png",
	# Finch head costumes, shown as the drop-zone targets during the match phase.
	"ground_head": "10_ground_finch_head.png", "tree_head": "11_tree_finch_head.png",
	"cactus_head": "12_cactus_finch_head.png", "warbler_head": "13_warbler_finch_head.png",
	"ground_fly": "24_ground_finch_flying.png", "ground_caught": "25_ground_finch.png",
	"warbler_fly": "26_warbler_finch_flying.png", "warbler_caught": "27_warbler_finch.png",
	"cactus_fly": "30_cactus_finch_flight.png", "cactus_caught": "31_cactus_finch.png",
	"veg_fly": "32_tree_finch_flight.png", "veg_caught": "33_tree_finch.png"
}

# Per-finch config: flying/caught costume, island background, food shown, and Darwin's
# narration line (verbatim from the CSnap project).
const FINCH = {
	"cactus": {
		"fly": "cactus_fly", "caught": "cactus_caught", "bg": "cactus_stage",
		"food": "cactus_bud", "line": "This bird is eating cactus buds."
	},
	"ground": {
		"fly": "ground_fly", "caught": "ground_caught", "bg": "ground_stage",
		"food": "seed", "line": "This bird is cracking these seeds open."
	},
	"vegetarian": {
		"fly": "veg_fly", "caught": "veg_caught", "bg": "veg_stage",
		"food": "berries", "line": "It looks like this bird is pulling berries off the branch."
	},
	"warbler": {
		"fly": "warbler_fly", "caught": "warbler_caught", "bg": "galapagos",
		"food": "fly", "line": "This bird appears to be eating insects."
	}
}

# Food items (Snap home position + sprite scale), shown during the matching finch's turn.
const FOOD = {
	"cactus_bud": {"pos": Vector2(-215, 125), "scale": 0.5},
	"seed": {"pos": Vector2(-15, 125), "scale": 0.6},
	"berries": {"pos": Vector2(-200, -50), "scale": 1.0},
	"fly": {"pos": Vector2(-25, -50), "scale": 0.7}
}

# Beak tools: costume, home position, correct drop-zone (placemarker) position, scale.
# Mapping is exactly the original: wirecutter->Sprite11, tweezers->Sprite12,
# pliers->Sprite10, needlenose->Sprite9.
const TOOLS = {
	"wirecutter": {"tex": "wirecutter", "home": Vector2(180, -135), "target": Vector2(-170, -130), "scale": 1.0},
	"tweezers": {"tex": "tweezers", "home": Vector2(180, -45), "target": Vector2(0, -130), "scale": 0.4},
	"pliers": {"tex": "pliers", "home": Vector2(180, 135), "target": Vector2(0, 45), "scale": 1.0},
	"needlenose": {"tex": "needlenose", "home": Vector2(180, 40), "target": Vector2(-170, 45), "scale": 1.0}
}

# Which finch head is shown at each tool's drop zone (beak shape -> matching finch),
# plus a display scale so the heads read at a consistent size.
const HEADS = {
	"wirecutter": {"tex": "tree_head", "scale": 0.75},
	"tweezers": {"tex": "warbler_head", "scale": 0.75},
	"pliers": {"tex": "ground_head", "scale": 0.42},
	"needlenose": {"tex": "cactus_head", "scale": 0.78}
}

signal finch_caught
signal all_matched
signal continue_pressed

var phase = "intro"
var active_finch = ""
var _fly_target = Vector2()
var _matched = 0
var _caught_count = 0
var _drag_tool = null
var _awaiting_continue = false

var bg
var darwin
var net_sprite
var box_sprite
var finch_sprites = {}
var food_sprites = {}
var tool_state = {}   # key -> {sprite, home, target, locked}

# UI (CanvasLayer, screen space)
var speech_label
var status_label
var done_label
var hint_label

func _ready():
	randomize()
	_build_world()
	_build_ui()
	_run_game()

# --- Snap -> Godot coordinate + sprite helpers ---

func s2g(sx, sy):
	return Vector2(OX + (sx + 240.0) * DISPLAY, (180.0 - sy) * DISPLAY)

func _tex(key):
	var p = DIR + TEX[key]
	if ResourceLoader.exists(p):
		return load(p)
	return null

func _make_sprite(texkey, snap_scale):
	var s = Sprite.new()
	s.texture = _tex(texkey)
	s.scale = Vector2(snap_scale * DISPLAY, snap_scale * DISPLAY)
	add_child(s)
	return s

func _build_world():
	# Dark letterbox backdrop behind the 4:3 stage.
	var back = Polygon2D.new()
	back.color = Color(0.06, 0.05, 0.04)
	back.polygon = PoolVector2Array([Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 720), Vector2(0, 720)])
	add_child(back)

	bg = Sprite.new()
	bg.position = s2g(0, 0)
	bg.scale = Vector2(DISPLAY, DISPLAY)
	add_child(bg)
	_set_bg("galapagos")

	box_sprite = _make_sprite("box", 1.0)
	box_sprite.position = s2g(200, -115)
	box_sprite.visible = false

	# One sprite per finch (flying costume) + its food item, hidden until its turn.
	for k in FINCH:
		var cfg = FINCH[k]
		var fsp = _make_sprite(cfg.fly, 1.0)
		fsp.visible = false
		finch_sprites[k] = fsp
		var food_key = cfg.food
		var fdp = _make_sprite(food_key, FOOD[food_key].scale)
		fdp.position = s2g(FOOD[food_key].pos.x, FOOD[food_key].pos.y)
		fdp.visible = false
		food_sprites[k] = fdp

	# Net (follows the mouse during the collect phase).
	net_sprite = _make_sprite("net", 1.0)
	net_sprite.visible = false

	# Beak tools (draggable during the match phase) + the finch head shown at each
	# tool's drop zone as the target to match against (hidden until the match phase).
	for k in TOOLS:
		var t = TOOLS[k]
		var target_pos = s2g(t.target.x, t.target.y)
		var hcfg = HEADS[k]
		var hsp = _make_sprite(hcfg.tex, hcfg.scale)
		hsp.position = target_pos
		hsp.z_index = 1
		hsp.visible = false
		var tsp = _make_sprite(t.tex, t.scale)
		var home = s2g(t.home.x, t.home.y)
		tsp.position = home
		tsp.z_index = 2
		tsp.visible = false
		tool_state[k] = {"sprite": tsp, "home": home, "target": target_pos, "head": hsp, "locked": false}

	# Darwin (nudged so the tall sprite stays on screen, bottom-left).
	darwin = _make_sprite("darwin", 0.85)
	darwin.position = Vector2(190, 545)

func _build_ui():
	var layer = CanvasLayer.new()
	layer.layer = 2
	add_child(layer)

	var speech_panel = Panel.new()
	speech_panel.margin_left = 240
	speech_panel.margin_top = 16
	speech_panel.margin_right = 1040
	speech_panel.margin_bottom = 70
	layer.add_child(speech_panel)
	speech_label = Label.new()
	speech_label.anchor_right = 1.0
	speech_label.anchor_bottom = 1.0
	speech_label.align = Label.ALIGN_CENTER
	speech_label.valign = Label.VALIGN_CENTER
	speech_label.autowrap = true
	speech_panel.add_child(speech_label)
	speech_panel.name = "SpeechPanel"

	status_label = Label.new()
	status_label.rect_position = Vector2(20, 20)
	status_label.rect_size = Vector2(420, 60)
	status_label.add_color_override("font_color", Color(1, 1, 1))
	layer.add_child(status_label)

	done_label = Label.new()
	done_label.rect_position = Vector2(340, 320)
	done_label.rect_size = Vector2(600, 80)
	done_label.align = Label.ALIGN_CENTER
	done_label.valign = Label.VALIGN_CENTER
	done_label.add_color_override("font_color", Color(1, 0.95, 0.6))
	done_label.visible = false
	layer.add_child(done_label)

	hint_label = Label.new()
	hint_label.rect_position = Vector2(340, 660)
	hint_label.rect_size = Vector2(600, 40)
	hint_label.align = Label.ALIGN_CENTER
	hint_label.valign = Label.VALIGN_CENTER
	hint_label.add_color_override("font_color", Color(1, 0.95, 0.6))
	hint_label.visible = false
	layer.add_child(hint_label)

func _set_bg(key):
	bg.texture = _tex(key)

func _say(text):
	speech_label.text = text

# Pause the sequence until the player presses Space (shows a prompt while waiting).
func _wait_continue(prompt = "▶  Press [Space] to continue"):
	_awaiting_continue = true
	hint_label.text = prompt
	hint_label.visible = true
	yield(self, "continue_pressed")
	hint_label.visible = false
	_awaiting_continue = false

# --- Game sequence (coroutine, mirrors the CSnap broadcasts) ---

func _run_game():
	_set_bg("galapagos")
	_say("Charles Darwin: I'll observe each bird to see what it's eating, then catch it to inspect it more closely.")
	yield(_wait_continue(), "completed")

	# Collect phase.
	phase = "collect"
	net_sprite.visible = true
	net_sprite.z_index = 10
	var order = ["cactus", "ground", "vegetarian", "warbler"]
	order.shuffle()
	for k in order:
		yield(_collect_one(k), "completed")
		_caught_count += 1
		_update_status()

	# Inspect / transition.
	phase = "transition"
	net_sprite.visible = false
	_set_bg("galapagos")
	_say("Charles Darwin: Time to inspect the specimens!")
	yield(_wait_continue(), "completed")
	_say("Charles Darwin: It looks like these birds all have different beaks. Match each beak to its finch.")
	yield(_wait_continue(), "completed")

	# Match phase.
	_set_bg("table")
	for k in tool_state:
		var t = tool_state[k]
		t.sprite.position = t.home
		t.sprite.visible = true
		t.head.visible = true
	phase = "match"
	_update_status()
	yield(self, "all_matched")

	# Done.
	phase = "done"
	for k in tool_state:
		tool_state[k].sprite.visible = false
		tool_state[k].head.visible = false
	_say("Charles Darwin: Excellent work matching the beaks!")
	status_label.text = ""
	done_label.text = "Specimens collected and beaks matched!"
	done_label.visible = true
	yield(_wait_continue("▶  Press [Space] to return to the courtroom"), "completed")
	_return_to_level3()

# Back to Level 3: its saved progress (fitzroy_return_done) resumes the courtroom.
# If Level3.tscn is somehow missing (e.g. running this scene on its own before the
# rest of the project exists), just stay on the end screen instead of crashing.
func _return_to_level3():
	if ResourceLoader.exists("res://Level3.tscn"):
		get_tree().change_scene("res://Level3.tscn")

# Runs one finch's collect turn: show its island/food, narrate, fly it around, and wait
# until the player catches it (clicks it with the net over it). Then it flies to the box.
func _collect_one(k):
	var cfg = FINCH[k]
	_set_bg(cfg.bg)
	food_sprites[k].visible = true
	_say("Charles Darwin: " + cfg.line)
	var sp = finch_sprites[k]
	sp.texture = _tex(cfg.fly)
	sp.scale = Vector2(DISPLAY, DISPLAY)
	sp.z_index = 5
	sp.position = s2g(0, 0)
	sp.visible = true
	active_finch = k
	_fly_target = _random_fly_point()
	_update_status()
	yield(self, "finch_caught")
	# Caught: switch to the standing costume, shrink, and glide into the box.
	active_finch = ""
	sp.texture = _tex(cfg.caught)
	sp.scale = Vector2(0.45 * DISPLAY, 0.45 * DISPLAY)
	sp.z_index = 1
	var box_pos = s2g(200, -115)
	var tw = 0.0
	while tw < 1.0:
		yield(get_tree(), "idle_frame")
		tw += 0.03
		sp.position = sp.position.linear_interpolate(box_pos, 0.15)
	sp.visible = false
	food_sprites[k].visible = false

func _random_fly_point():
	return s2g(rand_range(-200, 200), rand_range(-140, 140))

func _update_status():
	if phase == "collect":
		status_label.text = "Catch the finches:  " + str(_caught_count) + " / 4\n(aim the net, press [Space] to catch)"
	elif phase == "match":
		status_label.text = "Match the beaks:  " + str(_matched) + " / 4\n(drag each beak onto its finch)"
	else:
		status_label.text = ""

# --- Per-frame: net follows mouse; the active finch wanders ---

func _process(delta):
	if phase == "collect":
		net_sprite.position = get_global_mouse_position()
		if active_finch != "":
			var sp = finch_sprites[active_finch]
			sp.position = sp.position.move_toward(_fly_target, 260.0 * delta)
			if sp.position.distance_to(_fly_target) < 8.0:
				_fly_target = _random_fly_point()

# --- Input: catch (collect phase) and drag/drop (match phase) ---

func _input(event):
	# Space advances dialogue ("continue") and catches the netted finch.
	if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_SPACE:
		if _awaiting_continue:
			emit_signal("continue_pressed")
		elif phase == "collect" and active_finch != "":
			if _sprite_hit(finch_sprites[active_finch], get_global_mouse_position()):
				emit_signal("finch_caught")
		return
	# The match phase still needs the mouse for dragging beaks onto the finches.
	if phase == "match":
		_match_input(event)

func _match_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			for k in tool_state:
				var t = tool_state[k]
				if not t.locked and _sprite_hit(t.sprite, event.position):
					_drag_tool = k
					break
		else:
			if _drag_tool != null:
				var t = tool_state[_drag_tool]
				if t.sprite.position.distance_to(t.target) < 70.0:
					t.sprite.position = t.target
					t.locked = true
					_matched += 1
					_update_status()
					if _matched >= 4:
						emit_signal("all_matched")
				else:
					t.sprite.position = t.home
				_drag_tool = null
	elif event is InputEventMouseMotion and _drag_tool != null:
		tool_state[_drag_tool].sprite.position = event.position

# True if screen-space point is inside the sprite's (centred) drawn rectangle.
func _sprite_hit(sprite, point):
	if sprite.texture == null:
		return false
	var half = sprite.texture.get_size() * sprite.scale * 0.5
	var r = Rect2(sprite.position - half, half * 2.0)
	return r.has_point(point)
