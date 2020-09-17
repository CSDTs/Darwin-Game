extends Control

var start_menu
var level_select_menu


export (String, FILE) var court1
export (String, FILE) var level1


func _ready():
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu


	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_Open_Godot.connect("pressed", self, "start_menu_button_pressed", ["open_godot"])

	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])


	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level1.connect("pressed", self, "level_select_menu_button_pressed", ["level_one"])


	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)




func start_menu_button_pressed(button_name):
	if button_name == "start":
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "open_godot":
		OS.shell_open("https://godotengine.org/")
	elif button_name == "quit":
		get_tree().quit()


func level_select_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		level_select_menu.visible = false
	elif button_name == "level_one":
		get_node("/root/Globals").load_new_scene(level1)









