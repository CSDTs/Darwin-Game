extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var canMove = true;

# The NPC whose talk area the player is currently inside (or null). Set by NPCArea
# and read by the player's try_interact(), so talking uses the same range as the
# visible "Press Space to talk" prompt instead of a facing-direction raycast.
var current_npc = null

# --- Cumulative courtroom trial score (persists across Level 1 / 2 / 3) ---
# The running total for the WHOLE trial. Because Globals is an autoload it survives
# scene/level changes, so each level's courtroom result adds to these totals instead
# of the score resetting per round. Only a brand-new game resets it (see
# Main_Menu._ready -> reset_trial); nothing else should clear it.
var defense_score = 0
var prosecution_score = 0
# One-shot guard per level, so a level's courtroom result is counted exactly once
# even if its result screen is reopened or the scene reloads.
var result_applied = {"Level1": false, "Level2": false, "Level3": false}

# --- Per-level exploration progress (persists across Back / level select) ---
# Lets the player leave a level and return without losing collected artifacts, Case
# File entries, NPC-spoken flags, artifact unlocks, objectives or counters. Keyed by
# scene name ("Level1"/"Level2"/"Level3"); each value is a plain-data dict written by
# that level's _save_progress() and re-applied by its _restore_progress() on load.
# Because Globals is an autoload it survives scene changes; reset only by reset_trial()
# (Start / new game). Textures stored inside Case File entries are resources (not
# nodes), so they stay valid across scene reloads.
var level_progress = {}

# Stores (overwrites) a level's saved progress.
func save_level_progress(level_name, data):
	level_progress[level_name] = data

# Returns a level's saved progress, or null if it has never been saved (fresh game).
func get_level_progress(level_name):
	return level_progress.get(level_name, null)

# Adds one courtroom round's result to the running total, but only the first time a
# given level is scored. Strong / winning evidence scores for the Defense; weak /
# losing evidence scores for the Prosecution. Called from EvidenceSelect.show_result().
func apply_courtroom_result(level_name, defense_won):
	if result_applied.get(level_name, false):
		return
	result_applied[level_name] = true
	if defense_won:
		defense_score += 1
	else:
		prosecution_score += 1

# Resets the ENTIRE game for a brand-new game (called only from the main menu Start
# button). Clears the cumulative score, the per-level result guards, and all saved
# per-level exploration progress, so the next game starts completely fresh.
func reset_trial():
	defense_score = 0
	prosecution_score = 0
	result_applied = {"Level1": false, "Level2": false, "Level3": false}
	level_progress = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func updateMove(status):
	canMove = status;
