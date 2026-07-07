extends CanvasLayer

# Instruction line (bottom). Override per instance (e.g. "Press Space to talk").
export(String) var prompt_text = "Press Space to interact"
# Optional title line (top, more prominent). Empty = single-line prompt.
export(String) var title_text = ""

onready var globals = get_node("/root/Globals")
onready var panel = $Panel

# Set true by the owner (item / professor) while the player is within range.
var showing = false

func _ready():
	_apply()
	panel.visible = false

# Used by professors to set a "Role - Name" title above the instruction line.
func set_prompt(title, line):
	title_text = title
	prompt_text = line
	_apply()

# Lays out the box: compact single line, or a slightly taller/wider two-line box
# when a title is present.
func _apply():
	$Panel/VBox/Line.text = prompt_text
	if title_text == "":
		$Panel/VBox/Title.visible = false
		panel.margin_left = -125
		panel.margin_right = 125
		panel.margin_top = -78
	else:
		$Panel/VBox/Title.text = title_text
		$Panel/VBox/Title.visible = true
		panel.margin_left = -210
		panel.margin_right = 210
		panel.margin_top = -100

func set_showing(value):
	showing = value

func _process(delta):
	# Only show while in range AND the player is free to act, so it hides during
	# dialogue, the take/drop screen, the Case File, etc.
	panel.visible = showing and globals.canMove
