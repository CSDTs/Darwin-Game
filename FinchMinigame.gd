extends Node2D

# Finch Frenzy — a simple standalone "detox" minigame (first-pass foundation only).
# The player (Darwin) walks a small Galapagos-style island and "observes" finches
# before a 60-second timer runs out. This is intentionally minimal: basic movement,
# a countdown, a score, three stationary placeholder finches, and an end screen.
#
# It is NOT connected to the main Darwin story / courtroom / scoring in any way — it
# runs as its own scene. Nothing here touches the levels, Globals score, or artifacts.

# --- Tunable values ---
const START_TIME = 60.0
# Movement speed, matched to the main game's player (Lawyer moveSpeed = 250).
const MOVE_SPEED = 250.0
# The player is kept inside this rectangle (which sits inside the green island).
const BOUND_MIN = Vector2(240, 160)
const BOUND_MAX = Vector2(1040, 560)
# How close the player must get to a finch to "observe" it.
const OBSERVE_DIST = 55.0
# Target on-screen height for the Darwin sprite, so its source image size doesn't
# matter (the sprite is scaled to this in _ready).
const PLAYER_HEIGHT = 90.0

var time_left = START_TIME
var score = 0
# While true the timer counts down and the player can move; set false at time-up.
var running = true

onready var player = $Player
onready var finches = $Finches
onready var timer_label = $UI/Timer
onready var score_label = $UI/Score
onready var end_screen = $UI/EndScreen
onready var final_score_label = $UI/EndScreen/Panel/FinalScore
onready var return_button = $UI/EndScreen/Panel/ReturnButton

func _ready():
	# Normalise the Darwin sprite to a consistent height regardless of source size.
	if player.texture != null and player.texture.get_height() > 0:
		var s = PLAYER_HEIGHT / player.texture.get_height()
		player.scale = Vector2(s, s)
	end_screen.visible = false
	return_button.connect("pressed", self, "_on_continue_pressed")
	_update_timer_label()
	_update_score_label()

func _process(delta):
	if not running:
		return
	_handle_movement(delta)
	_check_finches()
	# Count the timer down; end the game when it hits zero.
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_end_game()
	_update_timer_label()

# Simple position-based movement (no physics) using the same input actions as the
# main game (WASD / arrow keys). The player is clamped to the island bounds.
func _handle_movement(delta):
	var vel = Vector2()
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	if Input.is_action_pressed("move_down"):
		vel.y += 1
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	vel = vel.normalized()
	player.position += vel * MOVE_SPEED * delta
	player.position.x = clamp(player.position.x, BOUND_MIN.x, BOUND_MAX.x)
	player.position.y = clamp(player.position.y, BOUND_MIN.y, BOUND_MAX.y)

# Placeholder "collection": walking near a finch observes it (hides it, +1 score).
# No finch AI, movement or respawning yet — that comes in a later pass.
func _check_finches():
	for finch in finches.get_children():
		if finch.visible and player.position.distance_to(finch.position) < OBSERVE_DIST:
			finch.visible = false
			score += 1
			_update_score_label()

# Time is up: stop movement (running = false gates _process) and show the end screen.
func _end_game():
	running = false
	final_score_label.text = "You observed " + str(score) + " finches."
	end_screen.visible = true

func _update_timer_label():
	timer_label.text = "Time: " + str(int(ceil(time_left)))

func _update_score_label():
	score_label.text = "Finches Observed: " + str(score)

# Continue to the Level 3 courtroom. The minigame is entered from Level 3's second
# Captain conversation, so returning to Level 3 resumes its saved progress and
# auto-enters the courtroom (Level3._restore_progress -> _enter_courtroom). No progress
# is reset by this transition.
func _on_continue_pressed():
	get_tree().change_scene("res://Level3.tscn")
