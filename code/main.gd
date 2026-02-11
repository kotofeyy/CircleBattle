extends Control

@onready var enemy_prefub: PackedScene = preload("res://enemy.tscn")
@onready var heart_preload: PackedScene = preload("res://heart.tscn")

@onready var panel: Panel = $CircleElements
@onready var score_label: Label = $ScoreLabel
@onready var audio_stream_player_succes: AudioStreamPlayer = $AudioStreamPlayerSucces
@onready var audio_stream_player_wrong: AudioStreamPlayer = $AudioStreamPlayerWrong
@onready var h_box_container: HBoxContainer = $HeartsControl/MarginContainer/HBoxContainer
@onready var animated_sprite_2d_hit: AnimatedSprite2D = $AnimatedSprite2DHit
@onready var end_game_panel: Panel = $EndGamePanel
@onready var start_game_button: Button = $StartGameButton
@onready var pause_button: Button = $PauseButton
@onready var final_scores_label: Label = $EndGamePanel/MarginContainer/VBoxContainer/FinalScoresLabel
@onready var shield_1: Panel = $CircleElements/Element/Shield
@onready var shield_2: Panel = $CircleElements/Element2/Shield

@onready var area_2d_shield_1: Area2D = $CircleElements/Element/Shield/Area2D
@onready var area_2d_shield_2: Area2D = $CircleElements/Element2/Shield/Area2D
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $TimerControl/HBoxContainer/TimerLabel
@onready var timer_control: Control = $TimerControl

@onready var elemen_2_line_direction_right: Line2D = $CircleElements/Elemen2LineDirectionRight
@onready var element_2_line_direction_left: Line2D = $CircleElements/Element2LineDirectionLeft
@onready var element_1_line_direction_right: Line2D = $CircleElements/Element1LineDirectionRight
@onready var element_1_line_direction_left: Line2D = $CircleElements/Element1LineDirectionLeft

var ELEMENT_FRIEND = preload("uid://nhx7jgro50t")

const PAUSE = preload("uid://bgjjb1igg1pw")
const PLAY = preload("uid://bocd2gvbpuc2a")


var direction: bool
var scores = 0
var chance_spawn_enemy = 0.15
var chance_spawn_shield = 0.2
var chance_spawn_heart = 0.9
var chance_spawn_friend = 0.5
var spawn_interval = 0.5
var health = 3
var game_is_start = false
var shield_is_enabled = false
var color_list = [Color.BURLYWOOD, Color.DARK_ORANGE, Color.DEEP_PINK, Color.INDIAN_RED, Color.SEA_GREEN]

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if game_is_start:
		if scores > 30:
			spawn_interval = 0.4
		if scores > 40:
			spawn_interval = 0.3
		if scores > 60:
			spawn_interval = 0.2

		if shield_is_enabled:
			enable_shield()
			timer_control.visible = true
		else:
			disable_shield()
			timer_control.visible = false

		if direction:
			panel.rotation_degrees += 50 * delta
		else:
			panel.rotation_degrees -= 50 * delta
	else:
		clear_enemies()
	if not timer.is_stopped():
		var time = timer.time_left
		
		var seconds = int(time) 
		var m_seconds = int((time - seconds) * 100) 
		
		# Форматируем: %02d значит "минимум 2 цифры, если меньше — подставить 0"
		timer_label.text = "%02d:%02d" % [seconds, m_seconds]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and event.is_action_pressed("mouse_action"):
		direction = !direction
		if direction:
			element_1_line_direction_left.visible = false
			element_2_line_direction_left.visible = false
			element_1_line_direction_right.visible = true
			elemen_2_line_direction_right.visible = true
		else:
			element_1_line_direction_left.visible = true
			element_2_line_direction_left.visible = true
			element_1_line_direction_right.visible = false
			elemen_2_line_direction_right.visible = false
		

func spawn_loop() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	while game_is_start:
		var position_x = randi_range(0, screen_size.x - 40)
		var chance = randf()
		var enemy: Enemy = enemy_prefub.instantiate()
		enemy.area_entered.connect(on_area_entered)
		if chance < chance_spawn_enemy:
			enemy.type_element = "enemy"
		if chance > chance_spawn_enemy and chance < chance_spawn_shield:
			enemy.type_element = "shield"
		if chance > chance_spawn_shield and chance < chance_spawn_friend:
			enemy.type_element = "friend"
		if chance > chance_spawn_heart:
			enemy.type_element = "heart"
		add_child(enemy)
		enemy.position = Vector2(position_x, screen_size.y)
		
		await get_tree().create_timer(spawn_interval).timeout
		
		if !game_is_start: return


func on_area_entered(type, pos) -> void:
	animated_sprite_2d_hit.position = pos
	animated_sprite_2d_hit.play("hit_white")
	if type == "friend":
		audio_stream_player_succes.play()
		scores += 1
		score_label_shake()
	if type == "heart":
		audio_stream_player_succes.play()
		if health < 3:
			health += 1
			add_heart()
	if type == "shield":
		audio_stream_player_succes.play()
		shield_is_enabled = true
		timer.start()
	if type == "enemy":
		if shield_is_enabled: audio_stream_player_succes.play()
		else:
			audio_stream_player_wrong.play()
			health -= 1
			remove_heart()
			score_label_wrong()
			if health < 1:
				game_is_start = false
				end_game_panel.visible = true
	#change_color_style_box()
	score_label.text = str(scores)
	final_scores_label.text = "Очков: " + str(scores)
	
func change_color_style_box() -> void:
	if scores > 0 and scores % 10 == 0:
		var color = color_list.pick_random()
		if color == ELEMENT_FRIEND.bg_color:
			change_color_style_box()
		else:
			ELEMENT_FRIEND.bg_color = color
	
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


func start_game() -> void:
	game_is_start = true
	score_label.text = str(scores)
	spawn_loop()
	add_heart()
	add_heart()
	add_heart()
	pause_button.visible = true


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


func _on_start_game_button_pressed() -> void:
	start_game()
	start_game_button.visible = false


func enable_shield() -> void:
	shield_1.visible = true
	shield_2.visible = true
	area_2d_shield_1.set_deferred("monitorable", true)
	area_2d_shield_2.set_deferred("monitorable", true)
	

func disable_shield() -> void:
	shield_1.visible = false
	shield_2.visible = false
	area_2d_shield_1.set_deferred("monitorable", false)
	area_2d_shield_2.set_deferred("monitorable", false)


func _on_timer_timeout() -> void:
	shield_is_enabled = false


func _on_pause_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		pause_button.icon = PLAY
	else:
		pause_button.icon = PAUSE
