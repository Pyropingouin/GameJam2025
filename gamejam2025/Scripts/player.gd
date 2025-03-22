extends Node2D

var maxHealth = 100
var currentHealth = 100
var defense = 0
var acorn = 0

@onready var healthBar: ProgressBar = $HealthBar
@onready var healthStatus: RichTextLabel = $HealthBar/HealthStatus
@onready var shield: Sprite2D = $HealthBar/Shield
@onready var shield_text: RichTextLabel = $HealthBar/ShieldText

func _ready() -> void:
	healthBar.max_value = maxHealth
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)
	if defense == 0:
		shield.visible = false
		shield_text.visible = false

func addHealth(healthToAdd: int) -> void:
	currentHealth += healthToAdd
	if currentHealth > maxHealth:
		currentHealth = maxHealth
	elif currentHealth < 0:
		currentHealth = 0
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)

func reduceHealth(damage: int) -> void:
	currentHealth -= (damage - defense)
	defense = 0
	shield.visible = false
	shield_text.visible = false
	if currentHealth < 0:
		currentHealth = 0
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)

func addMaxHealth(healthToAdd: int) -> void:
	maxHealth += healthToAdd
	if currentHealth > maxHealth: 
		currentHealth = maxHealth
	healthBar.value = maxHealth
	healthBar.max_value = maxHealth
	currentHealth = maxHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)

func addDefense(amount: int) -> void:
	defense += amount
	shield.visible = true
	shield_text.text = str(defense)

func addAcorns(amount: int) -> void:
	acorn += amount

func spendAcorns(amount: int) -> bool:
	if acorn >= amount:
		acorn -= amount
		return true
	else:
		return false
