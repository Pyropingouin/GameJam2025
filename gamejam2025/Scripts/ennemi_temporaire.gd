extends Node2D

signal hovered
signal hovered_off

@onready var card_manager: Node2D = $"../CardManager"
@onready var healthBar : ProgressBar = $HealthBar
@onready var healthStatus: RichTextLabel = $HealthBar/HealthStatus

@export var maxHealth: int = 100
@export var currentHealth: int = 100
@export var damageMultiplier: float = 1.0

func _ready() -> void:
	card_manager.connect_enemy_signals(self)
	
	healthBar.max_value = maxHealth
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_mouse_entered() -> void:
	#print("Hover squirrel")
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	#print("Hover off squirrel")
	emit_signal("hovered_off", self)

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
