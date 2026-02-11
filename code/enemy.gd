extends Panel
class_name Enemy

const ELEMENT_ENEMY = preload("uid://bd5ah7dx2gsdr")
const ELEMENT_FRIEND = preload("uid://nhx7jgro50t")
const ELEMENT_HEALTH = preload("uid://ciuglsimu31u0")


@export var speed: int = 150


signal area_entered

var type_element = "friend" ## friend or enemy or heart


func _ready() -> void:
	if type_element == "friend": add_theme_stylebox_override("panel", ELEMENT_FRIEND)
	if type_element == "heart": add_theme_stylebox_override("panel", ELEMENT_HEALTH)
	if type_element == "enemy": add_theme_stylebox_override("panel", ELEMENT_ENEMY)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", -50, 4.5)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func _on_area_2d_area_entered(_area: Area2D) -> void:
	emit_signal("area_entered", type_element, Vector2(position.x + size.x / 2, position.y + size.y / 2))
	queue_free()
