extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()
var screen_size #size of game window

signal hit

func _ready():
	screen_size = get_viewport_rect().size


func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.flip_v = velocity.y > 0


func _on_glow_body_entered(body):
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true) # Replace with function body.


func _on_box1_body_entered(body):
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)


func _on_box2_body_entered(body):
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)
