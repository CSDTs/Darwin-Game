extends Area2D

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(3)

# The small screen-space "Press Space to talk" prompt (sibling of this Area2D).
func _prompt():
	return get_parent().get_node("InteractionPrompt")

func _on_Area2D_body_entered(body):
	if(body.name == 'Lawyer'):
		var item = get_parent().item
		if get_parent().name == "Uncle" || get_parent().name == "Captain":
			if(item[0] != null && item[1] != null && item[2] != null):
				if (item[0].visible != true || item[1].visible != true || item[2].visible != true):
					get_parent().node.init_conversation(get_parent().name)
			else:
				get_parent().node.init_conversation(get_parent().name +'After')
		else:
			if(item != null):
				if(item.visible != true):
					get_parent().node.init_conversation(get_parent().name)
			else:
				get_parent().node.init_conversation(get_parent().name +'After')
		_prompt().set_showing(true)

func _on_Area2D_body_exited(body):
	if(body.name == 'Lawyer'):
		_prompt().set_showing(false)

func _on_Timer_timeout():
	pass
