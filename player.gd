extends CharacterBody2D

signal player_hit

@export var speed = 400
@export var jump_force = 600
@export var damage_value = 1
@export var checkpoint_path :NodePath
@export var max_health = 4
@export var level = 1
@export var gravity = 1500
@onready var anim_tree =  get_node("PivotNode/AnimationTree")

var HP_points = 4
var double_jump = false
var jump_window_timer = 0
var is_attacking = false
var enemy_pos = Vector2.ZERO
var hit = false
var enemy = null
var knockback_timer = 0.0
var xp_points = 0
var xp_for_next_level = 200
var level_up_count = 0
var dead = false
var checkpoint :Marker2D
var save_folder = "res://Saves/"
var added_hearts = 0
var player_name = Global.player_name
var current_level  = "res://Level1.tscn"
var main_menu = preload("res://main_menu.tscn")
var invincible = false

const JUMP_WINDOW = 0.01
const KNOCKBACK_DURATION = 1


func _ready():
	add_to_group("player")
	checkpoint = get_node(checkpoint_path)
	load_progress()
	global_position = checkpoint.global_position
	$Camera2D.reset_smoothing()


func _physics_process(delta):
	if HP_points == 0 and is_on_floor():
		is_attacking = false
		dead = true
		await get_tree().create_timer(2).timeout
		$HUD/RespawnButton.visible = true
	if not dead:
		var direction = 0
		if Input.is_action_pressed("move_right"):
			direction += 1
		if Input.is_action_pressed("move_left"):
			direction -=  1
		if direction != 0:
			velocity.x = direction * speed
		elif (not hit) and is_on_floor():
			velocity.x = 0
		if not is_on_floor():
			jump_window_timer += delta
			if Input.is_action_just_released("jump") and velocity.y < 0:
				velocity.y = 0
			if Input.is_action_just_pressed("jump") and double_jump:
				velocity.y = -jump_force + 200
				double_jump = false
			elif jump_window_timer>JUMP_WINDOW :
				velocity.y += gravity * delta
		else:
			jump_window_timer = 0
			if Input.is_action_just_pressed("jump"):
				velocity.y += -jump_force
				double_jump = true
			if Input.is_action_pressed("attack"):
				is_attacking = true
				if velocity.x == 0:
					anim_tree.get("parameters/playback").travel("attack_stand")
					$PivotNode/SwordSlash.play("sword_slash")
				else:
					anim_tree.get("parameters/playback").travel("attack_walk")
					$PivotNode/SwordSlash.play("sword_slash")
					
			if not Input.is_action_pressed("attack"):
				is_attacking = false
		move_and_slide()


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		$PauseMenu/PauseMenuLayout.visible = true
	if xp_points >= xp_for_next_level:
		level_up()
	update_labels()
	if not dead:
		if velocity.x != 0 :
			if velocity.x < 0:
				$PivotNode.scale.x = -1
			else:
				$PivotNode.scale.x = 1
		if not is_attacking :
			if is_on_floor():
				if velocity.x != 0 :
					anim_tree.get("parameters/playback").travel("walk")
				elif velocity.x == 0 and velocity.y == 0 :
					anim_tree.get("parameters/playback").travel("idle")
		if not is_on_floor():
			anim_tree.get("parameters/playback").travel("mid_air")
	else :
		anim_tree.get("parameters/playback").travel("death")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if (not dead) and (not invincible):
		emit_signal("player_hit")
		$InvincibilityTimer.start()
		invincible = true
		flash_on_hit()
		flashing()
		enemy = area.get_parent().get_parent()
		if enemy.is_in_group("Enemies"):
			enemy_pos = enemy.global_position
			hit = true
			HP_points = clamp(HP_points - enemy.damage_value, 0, max_health)
			$HUD.update_heart()
			if enemy_pos < global_position:
				velocity.x += enemy.knockback_power
				velocity.y += -150
			else:
				velocity.x += -enemy.knockback_power
				velocity.y += -150
		await get_tree().create_timer(0.1).timeout
		hit = false


func level_up():
	$LevelUpTimer.start()
	level += 1
	$LevelUp.visible = true
	level_up_count += 1 
	if level_up_count >= 2:
		max_health += 1
		damage_value += 1
		level_up_count = 0
		$HUD.add_heart()
		added_hearts += 1
	HP_points = max_health
	$HUD.update_heart()
	xp_points = xp_points - xp_for_next_level
	xp_for_next_level = level * 200


func _on_enemy_died(xp_gain):
	xp_points += xp_gain

func _on_level_up_timer_timeout() -> void:
	$LevelUp.visible = false


func update_labels():
	$HUD/XpLabel.text = "XP: " + str(xp_points) + "/" +str(xp_for_next_level)
	$HUD/Level.text = "Level: " + str(level)


func _on_hud_respawn() -> void:
	dead = false
	HP_points = max_health
	$HUD.update_heart()
	get_tree().reload_current_scene()


func _on_checkpoint_reached():
	checkpoint.global_position = global_position
	await get_tree().create_timer(1).timeout
	if HP_points < max_health:
		heal_all(max_health)
	save_progress()


func _on_checkpoint_entered():
	if HP_points < max_health:
		heal_all(max_health)
	save_progress()


func save_progress():
	var save_path = save_folder + player_name + ".LHK"
	var save_content ={
		"name" = player_name,
		"xp" = xp_points,
		"max" = max_health,
		"chpos_x" = checkpoint.global_position.x,
		"chpos_y" = checkpoint.global_position.y,
		"lvl" = level ,
		"lvl_count" = level_up_count,
		"add_hearts" = added_hearts,
		"damage" = damage_value,
		"current_level" = current_level
	}
	var file = FileAccess.open(save_path , FileAccess.WRITE)
	var json = JSON.stringify(save_content)
	file.store_string(json)
	file.close()


func load_progress():
	var save_path = save_folder + player_name + ".LHK"
	if FileAccess.file_exists(save_path) == true:
		var file = FileAccess.open(save_path , FileAccess.READ)
		var content = file.get_as_text()
		var save_content = JSON.parse_string(content)
		player_name = save_content["name"]
		xp_points = int(save_content["xp"])
		max_health = int(save_content["max"])
		checkpoint.global_position = Vector2(save_content["chpos_x"], save_content["chpos_y"])
		level = int(save_content["lvl"])
		level_up_count = save_content["lvl_count"]
		added_hearts = save_content["add_hearts"]
		damage_value = save_content["damage"]
		current_level = save_content["current_level"]
		HP_points = max_health
		xp_for_next_level = level * 200
		for i in range(added_hearts):
			$HUD.add_heart()
		$HUD.update_heart()


func _on_invincibility_timer_timeout() -> void:
	invincible = false
	$PivotNode/PlayerBottom.modulate.a = 1.0
	$PivotNode/PlayerTop.modulate.a = 1.0


func flash_on_hit():
	if not dead:
		$PivotNode/PlayerTop.modulate = Color(20, 20, 20)  
		$PivotNode/PlayerBottom.modulate = Color(20, 20, 20)
		await get_tree().create_timer(0.1).timeout 
		$PivotNode/PlayerTop.modulate = Color(1, 1, 1)  
		$PivotNode/PlayerBottom.modulate = Color(1, 1, 1)


func flashing():
	while invincible and (not dead):
		$PivotNode/PlayerTop.visible = false
		$PivotNode/PlayerBottom.visible = false
		await get_tree().create_timer(0.1).timeout
		$PivotNode/PlayerTop.visible = true
		$PivotNode/PlayerBottom.visible = true
		await get_tree().create_timer(0.1).timeout


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	global_position = checkpoint.global_position


func heal(amount):
	healing_flash()
	if HP_points < max_health:
		for i in range(amount):
			HP_points += 1
			$HUD.update_heart()



func heal_all(max_health):
	healing_flash()
	while HP_points < max_health:
		HP_points += 1
		$HUD.update_heart()
		await get_tree().create_timer(0.5).timeout


func healing_flash():
	$PivotNode/PlayerTop.modulate = Color(999, 999, 999)  
	$PivotNode/PlayerBottom.modulate = Color(999, 999, 999)
	await get_tree().create_timer(0.2).timeout
	$PivotNode/PlayerTop.modulate = Color(1, 1, 1)  
	$PivotNode/PlayerBottom.modulate = Color(1, 1, 1)


func _on_holy_butterfly_touched() -> void:
	heal(1)
