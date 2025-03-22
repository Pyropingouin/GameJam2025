extends Node2D

# Variables
var maxHealth = 100
var currentHealth = 100
var defense = 0
var maxEnergy = 4
var currentEnergy = 4
var acorn = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# You can initialize some UI elements or other components here if needed.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# You can handle things like regenerating energy or updating UI here.
	pass

# Function to add health (can be used to heal the player)
func addHealth(healthToAdd: int) -> void:
	currentHealth += healthToAdd
	if currentHealth > maxHealth:  # Prevent health from exceeding the maximum.
		currentHealth = maxHealth
	elif currentHealth < 0:  # Prevent health from going below 0 (e.g., dying).
		currentHealth = 0

# Function to reduce health (used for damage)
func reduceHealth(damage: int) -> void:
	currentHealth -= (damage - defense)
	if currentHealth < 0:
		currentHealth = 0

# Function to add max health (leveling up, etc.)
func addMaxHealth(healthToAdd: int) -> void:
	maxHealth += healthToAdd
	if currentHealth > maxHealth:  # If current health is above max, reset to max.
		currentHealth = maxHealth

# Function to regenerate energy (could be called every frame or triggered by events)
func regenerateEnergy(amount: int) -> void:
	currentEnergy += amount
	if currentEnergy > maxEnergy:  # Prevent energy from exceeding max.
		currentEnergy = maxEnergy

# Function to spend energy (e.g., for abilities or actions)
func spendEnergy(amount: int) -> bool:
	if currentEnergy >= amount:
		currentEnergy -= amount
		return true
	else:
		return false

# Function to add acorns (used for currency, collectibles, etc.)
func addAcorns(amount: int) -> void:
	acorn += amount

# Function to spend acorns (if needed, like buying items)
func spendAcorns(amount: int) -> bool:
	if acorn >= amount:
		acorn -= amount
		return true
	else:
		return false
		
		
func addDefense(amount: int) -> void:
	defense += amount
