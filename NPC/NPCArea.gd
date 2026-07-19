extends Area2D

onready var timer = $Timer
onready var globals = get_node("/root/Globals")

# True while the player (Lawyer) is inside this NPC's talk area.
var player_in_range = false

func _ready():
	timer.set_wait_time(3)

# The small screen-space "Press Space to talk" prompt (sibling of this Area2D).
func _prompt():
	return get_parent().get_node("InteractionPrompt")

func _on_Area2D_body_entered(body):
	# Only the player triggers NPC interaction; ignore walls, furniture, artifacts
	# or any other body that enters the area.
	if body != null and body.name == "Lawyer":
		player_in_range = true

func _on_Area2D_body_exited(body):
	if body != null and body.name == "Lawyer":
		player_in_range = false

# Keep the visible prompt AND the interaction target (globals.current_npc) driven
# by the same talk area, so pressing Space works from anywhere the prompt shows
# (no facing required) and both stop once the NPC has nothing left to say (e.g.
# Uncle after his one-time conversation).
func _process(delta):
	var parent = get_parent()
	if player_in_range and parent.can_talk():
		globals.current_npc = parent
		_prompt().set_showing(true)
	else:
		if globals.current_npc == parent:
			globals.current_npc = null
		_prompt().set_showing(false)

func _on_Timer_timeout():
	pass
