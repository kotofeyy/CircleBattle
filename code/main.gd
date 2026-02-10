extends Control

@onready var enemy_prefub: PackedScene = preload("res://enemy.tscn")
@onready var heart_preload: PackedScene = preload("res://heart.tscn")

@onready var panel: Panel = $Panel
@onready var score_label: Label = $ScoreLabel
@onready var audio_stream_player_succes: AudioStreamPlayer = $AudioStreamPlayerSucces
@onready var audio_stream_player_wrong: AudioStreamPlayer = $AudioStreamPlayerWrong
@onready var h_box_container: HBoxContainer = $HeartsControl/MarginContainer/HBoxContainer
@onready var animated_sprite_2d_hit: AnimatedSprite2D = $AnimatedSprite2DHit
@onready var end_game_panel: Panel = $EndGamePanel
@onready var final_scores_label: Label = $EndGamePanel/MarginContainer/VBoxContainer/FinalScoresLabel


var direction: bool
var scores = 0
var chance_spawn_eneemy = 0.15
var chance_spawn_heart = 0.30
var health = 3
var game_is_start = true


func _ready() -> void:
	score_label.text = str(scores)
	spawn_loop()
	add_heart()
	add_heart()
	add_heart()


func _physics_process(delta: float) -> void:
	if game_is_start:
		if direction:
			panel.rotation_degrees += 50 * delta
		else:
			panel.rotation_degrees -= 50 * delta
	else:
		end_game_panel.visible = true
		clear_enemies()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and event.is_action_pressed("mouse_action"):
		direction = !direction
		

func spawn_loop() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	while game_is_start:
		var position_x = randi_range(0, screen_size.x - 40)
		var chance = randf()
		var enemy: Enemy = enemy_prefub.instantiate()
		enemy.area_entered.connect(on_area_entered)
		if chance < chance_spawn_eneemy:
			enemy.type_element = "enemy"
		else:
			if chance < chance_spawn_heart:
			
				enemy.type_element = "heart"
			else:
				enemy.type_element = "friend"
		add_child(enemy)
		enemy.position = Vector2(position_x, screen_size.y)
		
		await get_tree().create_timer(0.5).timeout
		
		if !game_is_start: return


func on_area_entered(type, pos) -> void:
	print("health - ", health)
	animated_sprite_2d_hit.position = pos
	animated_sprite_2d_hit.play("hit_white")
	if type == "friend":
		audio_stream_player_succes.play()
		scores += 1
		score_label_shake()
		if scores > 10:
			chance_spawn_eneemy = 0.25
	if type == "heart":
		audio_stream_player_succes.play()
		if health < 3:
			health += 1
			add_heart()
	if type == "enemy":
		audio_stream_player_wrong.play()
		health -= 1
		remove_heart()
		score_label_wrong()
		if health < 1:
			game_is_start = false

	score_label.text = str(scores)
	final_scores_label.text = "Очков: " + str(scores)
	
	
func add_heart() -> void:
	var heart_inst = heart_preload.instantiate()
	h_box_container.add_child(heart_inst)


func remove_heart() -> void:
	var first_child = h_box_container.get_child(0)
	if first_child:
		first_child.queue_free()


func score_label_shake() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.5, 1.5), 0.1)
	tween.chain().tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)


func score_label_wrong() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(score_label, "rotation_degrees", 30, 0.1)
	tween.chain().tween_property(score_label, "rotation_degrees", 0, 0.1)


func _on_restart_game_button_pressed() -> void:
	end_game_panel.visible = false
	game_is_start = true
	spawn_loop()
	restart_game()


func restart_game() -> void:
	add_heart()
	add_heart()
	add_heart()
	health = 3
	scores = 0
	score_label.text = str(scores)


func clear_enemies() -> void:
	var children = get_children()
	for child in children:
		if child is Enemy:
			child.queue_free()
