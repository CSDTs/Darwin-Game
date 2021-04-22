extends Area2D

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(3)
	
func _on_Area2D_body_entered(body):
	if(body.name == 'Lawyer'):
		var item = get_parent().item
		if get_parent().name == "Uncle" || get_parent().name == "Captain":
			if(item[0] != null && item[1] != null && item[2] != null):
				if (item[0].visible != true || item[1].visible != true || item[2].visible != true):	
					get_parent().node.init_conversation(get_parent().name)
					$Control.visible = true
					timer.start()
			else:
				get_parent().node.init_conversation(get_parent().name +'After')
		else:
			if(item != null):
				if(item.visible != true):
					get_parent().node.init_conversation(get_parent().name)
					$Control.visible = true
					timer.start()
			else:
				get_parent().node.init_conversation(get_parent().name +'After')
	else:
		$Control.visible = false

func _on_Timer_timeout():
	$Control.visible=false
