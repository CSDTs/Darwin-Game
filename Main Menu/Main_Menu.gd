extends Control

var start_menu
var level_select_menu
var instructions

#These are scenes
export (String, FILE) var court1
export (String, FILE) var level1
export (String, FILE) var level2
export (String, FILE) var level3

func _ready():
	# NOTE: the trial score is intentionally NOT reset here. The main menu is reached
	# both by starting a new game AND by the in-level Back button, so resetting on menu
	# load would wipe the player's progress every time they press Back. The reset now
	# happens only when the player presses Start (see start_menu_button_pressed "run").
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu
	instructions = $Instructions

	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["run"])
	$Start_Menu/Button_CSDT.connect("pressed", self, "start_menu_button_pressed", ["open_CSDT"])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])
	$Start_Menu/Button_LevelSelect.connect("pressed", self, "start_menu_button_pressed", ["start"])

	#$ButtonLevel1.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level1.connect("pressed", self, "level_select_menu_button_pressed", ["level_one"])
	$Level_Select_Menu/Button_Level2.connect("pressed", self, "level_select_menu_button_pressed", ["level_two"])
	$Level_Select_Menu/Button_Level3.connect("pressed", self, "level_select_menu_button_pressed", ["level_three"])

	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])
	$Instructions/Button_Continue.connect("pressed", self, "launch_courtroom")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	OS.min_window_size = Vector2(1024, 600)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if $Instructions.visible == true:
			get_tree().change_scene("res://Courtroom.tscn")
		
func start_menu_button_pressed(button_name):
	if button_name == "start":
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "open_CSDT":
		OS.shell_open("https://csdt.org/culture/darwingame/index.html")
	elif button_name == "quit":
		get_tree().quit()
	elif button_name == 'run':
		# Start = the intentional "new game". This is the ONLY place the full trial
		# resets: cumulative Defense/Prosecution scores back to 0-0 and the per-level
		# "result already applied" flags cleared. Back / level select never reset.
		get_node("/root/Globals").reset_trial()
		instructions.visible = true
		#get_node("/root/Globals").load_new_scene(court1)

func launch_courtroom():
	get_tree().change_scene("res://Courtroom.tscn")

func level_select_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		level_select_menu.visible = false
	elif button_name == "level_one":
		get_tree().change_scene("res://Level1.tscn")
	elif button_name == "level_two":
		get_tree().change_scene("res://Level2.tscn")
	elif button_name == "level_three":
		get_tree().change_scene("res://Level3.tscn")









