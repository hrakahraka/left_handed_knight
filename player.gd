extends CharacterBody2D



@export var speed = 400
@export var jump_force = 600
@export var damage_value = 50
@export var HP_points = 200
@export var gravity = 1500
@onready var anim_tree =  get_node("PivotNode/AnimationTree")

var double_jump = false
var jump_window_timer = 0
var is_attacking = false
var enemy_pos = Vector2.ZERO
var hit = false
var enemy = null
var knockback_timer = 0.0
const JUMP_WINDOW = 0.01
const KNOCKBACK_DURATION = 1


func _ready():
	add_to_group("player")


func _physics_process(delta):
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
		if Input.is_action_just_released("jump"):
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
		if Input.is_action_pressed("attack") and is_on_floor():
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


func _on_hurtbox_area_entered(area: Area2D) -> void:
	enemy = area.get_parent().get_parent()
	if enemy.is_in_group("Enemies"):
		enemy_pos = enemy.global_position
		hit = true
		
		if enemy_pos < global_position:
			velocity.x += 400
			velocity.y += -150
		else:
			velocity.x += -400
			velocity.y += -150
	await get_tree().create_timer(0.1).timeout
	hit = false
