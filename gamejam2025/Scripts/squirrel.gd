extends Node2D

# Variables
@export var maxHealth: int = 100
@export var currentHealth: int = 100
@export var damageMultiplier: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# You can initialize some UI elements or other components here if needed.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# You can handle things like regenerating energy or updating UI here.
	pass
	
# Function to handle an attack
func attack(target: Node2D, damage: int) -> void:
	# Calculate the damage
	var damageDealt = damage * damageMultiplier
	
	# If the target has a reduceHealth function, deal damage
	if target.has_method("reduceHealth"):
		target.reduceHealth(damageDealt)

# Function to reduce health (used for damage)
func reduceHealth(damage: int) -> void:
	currentHealth -= damage
	if currentHealth < 0:
		currentHealth = 0
