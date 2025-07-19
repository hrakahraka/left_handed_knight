extends CharacterBody2D



@export var speed = 400
@export var jump_force = 600
@export var gravity = 1500
var double_jump = false
var jump_window_timer = 0
var is_attacking = false
const JUMP_WINDOW =0.04


func _ready():
	add_to_group("player")


func _physics_process(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	if not is_on_floor():
		jump_window_timer += delta
		if jump_window_timer>JUMP_WINDOW:
			if Input.is_action_just_pressed("jump") and double_jump:
				velocity.y = -jump_force + 200
				double_jump = false
			else:
				velocity.y += gravity * delta
	else:
		jump_window_timer = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
			double_jump = true
	move_and_slide()
	
	
func _process(delta):
	if Input.is_action_pressed("attack") and is_attacking == false:
		is_attacking = true
		$PivotNode/AnimatedSprite2D.play("attack")
	if Input.is_action_just_released("attack"):
		is_attacking = false
	if velocity.x != 0 :
		if velocity.x < 0:
			$PivotNode.scale.x = -1
		else:
			$PivotNode.scale.x = 1
	if is_on_floor():
		if velocity.x != 0 :
			if $PivotNode/AnimatedSprite2D.animation != "walk":
				$PivotNode/AnimatedSprite2D.play("walk")
		elif velocity.x == 0 and velocity.y == 0 :
			if $PivotNode/AnimatedSprite2D.animation != "idle":
				$PivotNode/AnimatedSprite2D.play("idle")
	elif not is_on_floor():
		if $PivotNode/AnimatedSprite2D.animation != "mid_air":
				$PivotNode/AnimatedSprite2D.play("mid_air")
