extends Node2D

#Scenes
@onready var main_menu_scene: Node2D = $MainMenuScene
@onready var tree_scene: Node2D = $TreeScene
@onready var combat_scene: Node2D = $CombatScene
@onready var final_win_scene: Node2D = $FinalWinScene
@onready var lose_scene: Node2D = $LoseScene
@onready var credits_scene: Node2D = $CreditsScene

@onready var audio_manager: Node2D = $AudioManager

func _ready() -> void:
	connect_main_menu_signals()
	connect_credits_signals()
	connect_lose_screen_signals()
	
func connect_main_menu_signals():
	main_menu_scene.connect("start_game_button_pressed", Callable(self, "_on_start_game_pressed"))
	main_menu_scene.connect("enter_credits_button_pressed", Callable(self, "_on_credit_pressed"))

func connect_credits_signals():
	credits_scene.connect("back_to_menu_button_pressed", Callable(self, "_on_back_to_menu_pressed"))
	
func connect_lose_screen_signals():
	lose_scene.connect("back_to_menu_button_pressed", Callable(self, "_on_back_to_menu_pressed"))
	
func _on_start_game_pressed():
	main_menu_scene.visible = false
	enter_tree_scene()
	
func _on_credit_pressed():
	all_invisible()
	credits_scene.visible = true

func _on_back_to_menu_pressed():
	all_invisible()
	main_menu_scene.visible = true
	
func enter_tree_scene():
	all_invisible()
	tree_scene.visible = true
	
	audio_manager.get_node("BattleMusic").stop()
	audio_manager.get_node("TreeMusic").play() 

func enter_credits_scene():
	all_invisible()
	credits_scene.visible = true

func all_invisible():
	main_menu_scene.visible = false
	tree_scene.visible = false
	combat_scene.visible = false
	credits_scene.visible = false
	final_win_scene.visible = false
	lose_scene.visible = false
