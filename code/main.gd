extends Control
@onready var panel: Panel = $Panel


var direction: bool


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if direction:
		panel.rotation_degrees += 50 * delta
	else:
		panel.rotation_degrees -= 50 * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and event.is_action_pressed("mouse_action"):
		direction = !direction
