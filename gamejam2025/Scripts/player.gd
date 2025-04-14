extends Node2D

var max_health: int = 100
var current_health: int = max_health
var defense: int = 0
var acorn: int = 0

@onready var healthBar: ProgressBar = $HealthBar
@onready var healthStatus: RichTextLabel = $HealthBar/HealthStatus
@onready var shield: Sprite2D = $HealthBar/Shield
@onready var shield_text: RichTextLabel = $HealthBar/ShieldText

signal died

func _ready() -> void:
	healthBar.max_value = max_health
	updateHealthUI()
	updateDefenseUI()

func updateHealthUI():
	current_health = clamp(current_health, 0, max_health)
	healthBar.value = current_health
	healthStatus.text = "%d/%d" % [current_health, max_health]

func updateDefenseUI():
	shield_text.text = "[center]%d[/center]" % [defense]
	shield.visible = defense > 0
	shield_text.visible = defense > 0

func addHealth(amount: int) -> void:
	current_health += amount
	updateHealthUI()

func reduceHealth(damage: int) -> void:
	if damage > defense:
		current_health -= (damage - defense)
	defense = max(0, defense - damage)

	updateHealthUI()
	updateDefenseUI()

	if current_health <= 0:
		emit_signal("died")

func addMaxHealth(amount: int) -> void:
	max_health += amount
	current_health = max_health
	healthBar.max_value = max_health
	updateHealthUI()

func addDefense(amount: int) -> void:
	defense += amount
	updateDefenseUI()

func addAcorns(amount: int) -> void:
	acorn += amount

func spendAcorns(amount: int) -> bool:
	if acorn >= amount:
		acorn -= amount
		return true
	return false

func resetPlayer():
	current_health = max_health
	healthBar.max_value = max_health
	updateHealthUI()
