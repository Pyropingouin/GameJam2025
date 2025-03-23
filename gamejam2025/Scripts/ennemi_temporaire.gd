extends Node2D

signal hovered
signal hovered_off
signal died

@onready var card_manager: Node2D = $"../CardManager"
@onready var healthBar : ProgressBar = $HealthBar
@onready var healthStatus: RichTextLabel = $HealthBar/HealthStatus
@onready var shield: Sprite2D = $Shield
@onready var shield_text: RichTextLabel = $ShieldText



@export var maxHealth: int = 100
@export var currentHealth: int = 100
@export var damageMultiplier: float = 1.0


var defense = 0


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
	if damage > defense:
		currentHealth -= (damage - defense)
	defense = max(0, defense - damage)
	shield_text.text = "[center]"+str(defense)+"[center]"
	if defense < 1:
		shield.visible = false
		shield_text.visible = false
	if currentHealth < 0:
		currentHealth = 0
	healthBar.value = currentHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)
	
	if currentHealth <= 0:
		emit_signal("died")
	
func setDefense(amount: int):
	defense += amount
	shield.visible = true
	shield_text.text = "[center]"+str(defense)+"[center]"
	
func setEnnemy(sn):
	get_node("Sprite2D").texture = sn.squirrel_image
	maxHealth = sn.hp
	currentHealth = maxHealth
	
	damageMultiplier= sn.dmgMult
	
	

	
	healthBar.value = currentHealth
	healthBar.max_value = maxHealth
	healthStatus.text = str(currentHealth) + "/" + str(maxHealth)
	
	
