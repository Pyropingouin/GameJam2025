extends Node2D

signal hovered
signal hovered_off
signal died

@onready var card_manager: Node2D = $"../CardManager"
@onready var healthBar : ProgressBar = $HealthBar
@onready var healthStatus: RichTextLabel = $HealthBar/HealthStatus
@onready var shield: Sprite2D = $HealthBar/Shield
@onready var shield_text: RichTextLabel = $HealthBar/ShieldText

var max_health: int = 100
var current_health: int = max_health
var damage_multiplier: float = 1.0
var defense: int = 0
var audio_attack: AudioStream
var squirrel_type: String = "Normal"
var squirrel_name: String = "Squirrel"

func _ready() -> void:
	card_manager.connect_enemy_signals(self)
	
	updateHealthUI()
	updateDefenseUI()

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

func updateHealthUI():
	current_health = clamp(current_health, 0, max_health)
	healthBar.value = current_health
	healthBar.max_value = max_health
	healthStatus.text = "%d/%d" % [current_health, max_health]

func updateDefenseUI():
	shield_text.text = "[center]%d[/center]" % [defense]
	shield.visible = defense > 0
	shield_text.visible = defense > 0

func attack(target: Node2D, damage: int) -> void:
	if target.has_method("reduceHealth"):
		target.reduceHealth(damage * damage_multiplier)

func reduceHealth(damage: int) -> void:
	if damage > defense:
		current_health -= (damage - defense)
	defense = max(0, defense - damage)
	
	updateHealthUI()
	updateDefenseUI()
	
	if current_health <= 0:
		emit_signal("died")
	
func setDefense(amount: int):
	defense += amount
	updateDefenseUI()
	
func setEnnemy(ennemy):
	get_node("Sprite2D").sprite_frames = ennemy.squirrel_frames
	get_node("Sprite2D").play("idle")
	
	max_health = ennemy.hp
	current_health = max_health
	damage_multiplier= ennemy.dmgMult
	audio_attack = ennemy.attack_audio
	squirrel_type = ennemy.type
	squirrel_name = ennemy.squirrel_name
	damage_multiplier = ennemy.dmgMult

	updateHealthUI()
	
