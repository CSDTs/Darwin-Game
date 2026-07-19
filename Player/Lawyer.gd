extends KinematicBody2D
var moveSpeed : int = 250
var interactDist : int = 240

var vel = Vector2()
var facingDir = Vector2()

onready var globals = get_node("/root/Globals")
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	# Only interact while the player is free to act, so Space does nothing while a
	# dialogue, evidence card, Case File, strength selection, professor question
	# menu or courtroom evidence UI is open (they all disable movement).
	if Input.is_action_just_pressed("interact") and globals.canMove:
		try_interact()

func _physics_process (delta):
	# When the player is locked (artifact pickup prompt, dialogue, etc.) ignore ALL
	# movement input and bail out, so keys like D — which is also "drop" — never move
	# the player while the artifact screen is open.
	if not globals.canMove:
		return

	vel = Vector2()
	# inputs
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
		facingDir = Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		vel.y += 1
		facingDir = Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
		facingDir = Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		vel.x += 1
		facingDir = Vector2(1, 0)

	# normalize the velocity to prevent faster diagonal movement
	vel = vel.normalized()

	# move the player
	move_and_slide(vel * moveSpeed, Vector2.ZERO)

	# Manage the Animations
	manage_animations()


func manage_animations ():
	
	if vel.x > 0:
		play_animation("MoveRight")
	elif vel.x < 0:
		play_animation("MoveLeft")
	elif vel.y < 0:
		play_animation("MoveUp")
	elif vel.y > 0:
		play_animation("MoveDown")
	elif facingDir.x == 1:
		play_animation("IdleRight")
	elif facingDir.x == -1:
		play_animation("IdleLeft")
	elif facingDir.y == -1:
		play_animation("IdleUp")
	elif facingDir.y == 1:
		play_animation("IdleDown")
		

func play_animation (anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)
		
func try_interact ():
	
	# NPCs first: if the player is inside an NPC's talk area, talk to it. This uses
	# the same range that shows the "Press Space to talk" prompt, so no facing is
	# required (fixes the prompt-visible-but-can't-interact mismatch).
	if globals.current_npc != null and is_instance_valid(globals.current_npc) and globals.current_npc.can_talk():
		globals.current_npc.start_conversation()
		return
	# Otherwise, a facing-based raycast for items / other interactables. Only call
	# interaction functions on objects that actually implement them, so plain
	# StaticBody2D collision objects (walls, tables, furniture) are ignored instead
	# of crashing. Artifacts have setItemControlLayer; others may use on_interact.
	rayCast.cast_to = facingDir * interactDist
	rayCast.force_raycast_update()
	if not rayCast.is_colliding():
		return
	var target = rayCast.get_collider()
	if target.has_method("on_interact"):
		target.on_interact(self)
	elif target.has_method("setItemControlLayer"):
		target.setItemControlLayer(true)

