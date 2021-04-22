extends KinematicBody2D
var moveSpeed : int = 250
var interactDist : int = 70

var vel = Vector2()
var facingDir = Vector2()

onready var globals = get_node("/root/Globals")
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process (delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()

func _physics_process (delta):
	
	if(globals.canMove == true):
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
	
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		if rayCast.get_collider() is KinematicBody2D:
			rayCast.get_collider().start_conversation()
			print(rayCast.get_collider().name)
		elif rayCast.get_collider().has_method("on_interact"):
			 rayCast.get_collider().on_interact(self)
		elif rayCast.get_collider() is StaticBody2D:
			rayCast.get_collider().setItemControlLayer(true)

