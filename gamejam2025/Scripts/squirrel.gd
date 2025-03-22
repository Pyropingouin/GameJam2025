extends Node2D

@export var maxHealth: int = 100
@export var currentHealth: int = 100
@export var damageMultiplier: float = 1.0

@onready var healthBar : ProgressBar = $HealthBar
@onready var healthStatus: RichTextLabel = $HealthBar/HealthStatus

func _ready() -> void:
	healthBar.max_value = maxHealth
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)

func attack(target: Node2D, damage: int) -> void:
	var damageDealt = damage * damageMultiplier

	if target.has_method("reduceHealth"):
		target.reduceHealth(damageDealt)

func reduceHealth(damage: int) -> void:
	currentHealth -= damage
	if currentHealth < 0:
		currentHealth = 0
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)
