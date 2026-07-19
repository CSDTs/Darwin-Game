extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var canMove = true;

# The NPC whose talk area the player is currently inside (or null). Set by NPCArea
# and read by the player's try_interact(), so talking uses the same range as the
# visible "Press Space to talk" prompt instead of a facing-direction raycast.
var current_npc = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func updateMove(status):
	canMove = status;
