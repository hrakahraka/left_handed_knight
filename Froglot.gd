extends CharacterBody2D
var change_direction = false
@export var speed = 200
@export var damage_value = 20
@export var HP_points = 150
@export var gravity = 1500
var direction = 1
var player = null
var player_pos = Vector2.ZERO
var player_detected = false


func _ready() :
	add_to_group("Enemies")
	player = get_tree().get_nodes_in_group("player")[0]


func _physics_process(delta):
	if $PivotNode/LineOfSight.is_colliding():
		player_detected = true
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = speed * direction
		velocity.y -= 300
	if not player_detected :
		if $PivotNode/WallCheck.is_colliding() or not ($PivotNode/EdgeCheck.is_colliding()):
			direction *= -1
			$PivotNode.scale.x *= -1
	elif player_detected and is_on_floor():
		if player.global_position > global_position:
			direction = 1
			$PivotNode.scale.x = 1
		elif player.global_position < global_position:
			direction = -1
			$PivotNode.scale.x = -1
	move_and_slide()
	


func _process(delta: float) -> void:
	pass


func _on_hurtbox_area_entered(area: Area2D) -> void:
	player_pos = player.global_position
	if player.is_attacking :
		if player_pos < global_position:
			velocity.x += 500
			velocity.y += -200
		else:
			velocity.x += -500
			velocity.y += -200
	else:
		pass
