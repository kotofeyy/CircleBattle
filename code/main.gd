extends Control


@onready var panel: Panel = $Panel
@onready var score_label: Label = $ScoreLabel
@onready var enemy_prefub: PackedScene = preload("res://enemy.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


var direction: bool
var scores = 0
var chance_spawn_eneemy = 0.15
var health = 3
var game_is_start = true

func _ready() -> void:
	score_label.text = str(scores)
	spawn_loop()

func _physics_process(delta: float) -> void:
	if direction:
		panel.rotation_degrees += 50 * delta
	else:
		panel.rotation_degrees -= 50 * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and event.is_action_pressed("mouse_action"):
		direction = !direction
		

func spawn_loop() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	while game_is_start:
		var position_x = randi_range(0, screen_size.x - 40)
		var chance = randf()
		print("шанс - ", chance)
		var enemy: Enemy = enemy_prefub.instantiate()
		enemy.area_entered.connect(on_area_entered)
		if chance < chance_spawn_eneemy:
			enemy.type_element = "enemy"
		else:
			enemy.type_element = "friend"
		add_child(enemy)
		enemy.position = Vector2(position_x, screen_size.y)
		
		await get_tree().create_timer(0.5).timeout
		
		if !game_is_start: return


func on_area_entered(type) -> void:
	if type == "friend":
		scores += 1
		if scores > 10:
			chance_spawn_eneemy = 0.25
	else:
		health -= 1
		if health < 1:
			game_is_start = false
		

	score_label.text = str(scores)
	
	audio_stream_player.play()
