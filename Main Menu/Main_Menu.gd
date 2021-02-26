extends Control

var start_menu
var level_select_menu

#These are scenes
export (String, FILE) var court1
export (String, FILE) var level1
export (String, FILE) var level2
export (String, FILE) var level3


func _ready():
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu

	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_CSDT.connect("pressed", self, "start_menu_button_pressed", ["open_CSDT"])

	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])

	#$ButtonLevel1.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level1.connect("pressed", self, "level_select_menu_button_pressed", ["level_one"])
	$Level_Select_Menu/Button_Level2.connect("pressed", self, "level_select_menu_button_pressed", ["level_two"])
	$Level_Select_Menu/Button_Level3.connect("pressed", self, "level_select_menu_button_pressed", ["level_three"])

	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func start_menu_button_pressed(button_name):
	if button_name == "start":
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "open_CSDT":
		OS.shell_open("https://csdt.org/culture/darwingame/index.html")
	elif button_name == "quit":
		get_tree().quit()


func level_select_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		level_select_menu.visible = false
	elif button_name == "level_one":
		get_node("/root/Globals").load_new_scene(level1)
	elif button_name == "level_two":
		get_node("/root/Globals").load_new_scene(level2)
	elif button_name == "level_three":
		get_node("/root/Globals").load_new_scene(level3)









