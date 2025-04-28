extends Node2D

#Scenes
@onready var main_menu_scene: Node2D = $MainMenuScene
@onready var tree_scene: Node2D = $TreeScene
@onready var combat_scene: Node2D = $CombatScene
@onready var final_win_scene: Node2D = $FinalWinScene
@onready var lose_scene: Node2D = $LoseScene
@onready var credits_scene: Node2D = $CreditsScene

@onready var audio_manager: Node2D = $AudioManager

var win_screen 

func _ready() -> void:
	win_screen = combat_scene.get_node("WinScreen")
	connect_main_menu_signals()
	connect_credits_signals()
	connect_final_win_screen_signals()
	connect_win_screen_signals()
	connect_lose_screen_signals()
	connect_tree_signals()
	connect_battle_manager_signals()
	
func connect_main_menu_signals():
	main_menu_scene.connect("start_game_button_pressed", Callable(self, "_on_start_game_pressed"))
	main_menu_scene.connect("enter_credits_button_pressed", Callable(self, "_on_credit_pressed"))

func connect_credits_signals():
	credits_scene.connect("back_to_menu_button_pressed", Callable(self, "_on_back_to_menu_pressed"))

func connect_final_win_screen_signals():
	final_win_scene.connect("restart_button_pressed", Callable(self, "_on_restart_game"))

func connect_win_screen_signals():
	win_screen.connect("next_button_pressed", Callable(self, "_on_next_button_pressed"))

func connect_lose_screen_signals():
	lose_scene.connect("restart_button_pressed", Callable(self, "_on_restart_game"))
	
func connect_tree_signals():
	tree_scene.connect("combat_requested", Callable(self, "_on_combat_requested"))
	
func connect_battle_manager_signals():
	var battle_manager = combat_scene.get_node("BattleManager")

	battle_manager.connect("player_died", Callable(self, "_on_player_died"))
	battle_manager.connect("enemy_died", Callable(self, "_on_enemy_died"))
	battle_manager.connect("game_victory", Callable(self, "_on_game_victory"))
	battle_manager.connect("combat_requested", Callable(self, "_on_combat_requested"))
	
func _on_start_game_pressed():
	main_menu_scene.visible = false
	enter_tree_scene()
	
func _on_credit_pressed():
	all_invisible()
	credits_scene.visible = true

func _on_back_to_menu_pressed():
	all_invisible()
	main_menu_scene.visible = true
	
func _on_restart_game():
	_on_back_to_menu_pressed()
	
	get_tree().reload_current_scene()
	
func _on_combat_requested(squirrel):
	all_invisible()
	combat_scene.visible = true
	win_screen.visible = false
	audio_manager.get_node("EngageBattle").play()
	audio_manager.get_node("TreeMusic").stop()
	audio_manager.get_node("BattleMusic").play() 

func _on_player_died():
	all_invisible()
	lose_scene.visible = true

func _on_enemy_died():
	var win_screen = combat_scene.get_node("WinScreen")
	var end_turn_button = combat_scene.get_node("EndTurnButton")
	
	win_screen.visible = true
	end_turn_button.visible = false

func _on_game_victory():
	all_invisible()
	final_win_scene.visible = true
	
func _on_next_button_pressed():
	enter_tree_scene()
	tree_scene.get_node("info_panel").visible = false
	
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
	tree_scene.get_node("info_panel").visible = false
