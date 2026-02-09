extends Panel
class_name Enemy

const ELEMENT_ENEMY = preload("uid://bd5ah7dx2gsdr")
const ELEMENT_FRIEND = preload("uid://nhx7jgro50t")

@export var speed: int = 150


signal area_entered

var type_element = "friend" ## friend or enemy


func _ready() -> void:
	if type_element == "friend": add_theme_stylebox_override("panel", ELEMENT_FRIEND)
	else: add_theme_stylebox_override("panel", ELEMENT_ENEMY)


func _physics_process(delta: float) -> void:
	position.y -= speed * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	emit_signal("area_entered", type_element)
	queue_free()
