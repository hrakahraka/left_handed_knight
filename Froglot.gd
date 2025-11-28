extends CharacterBody2D

signal killed(xp_gain)


@export var speed = 200
@export var damage_value = 1
@export var HP_points = 2
@export var gravity = 1500
@export var knockback_power = 400
@export var xp_gain = 30

var direction = 1
var player = null
var player_pos = Vector2.ZERO
var player_detected = false
var jumpable = false
var dead = false
var death_animation_played = false
var change_direction = false


func _ready() :
	add_to_group("Enemies")
	player = get_tree().get_nodes_in_group("player")[0]
	if player:
		connect("killed", Callable(player, "_on_enemy_died"))


func _physics_process(delta):
	if HP_points <= 0 and is_on_floor():
		dead = true
		$PivotNode/hurtbox/CollisionShape2D.disabled = true
	if dead and (not death_animation_played):
		emit_signal("killed", xp_gain)
		$PivotNode/AnimatedSprite2D.play("dead")
		death_animation_played = true
	if not dead:
		var target_front = $PivotNode/LineOfSight.get_collider()
		var target_Back = $PivotNode/BackCheck.get_collider()
		if ($PivotNode/LineOfSight.is_colliding() and target_front.name == "Player") or ($PivotNode/BackCheck.is_colliding() and target_Back.name == "Player"):
			player_detected = true
		if not is_on_floor():
			velocity.y += gravity * delta
			$PivotNode/AnimatedSprite2D.play("jump")
		elif is_on_floor():
			$PivotNode/AnimatedSprite2D.play("idle")
			velocity = Vector2.ZERO
			if jumpable:
				velocity.x = speed * direction
				velocity.y = -300
		if not player_detected :
			if $PivotNode/WallCheck.is_colliding() or not ($PivotNode/EdgeCheck.is_colliding()):
				direction *= -1
				$PivotNode.scale.x *= -1
		elif player_detected :
			if (player.global_position > global_position) and is_on_floor():
				direction = 1
				$PivotNode.scale.x = 1
			elif (player.global_position < global_position) and is_on_floor():
				direction = -1
				$PivotNode.scale.x = -1
		move_and_slide()
	


func _process(delta: float) -> void:
	pass


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not dead:
		player_pos = player.global_position
		HP_points -= player.damage_value
		
		if player_pos < global_position:
			velocity.x += 500
			velocity.y += -200
		else:
			velocity.x += -500
			velocity.y += -200


func _on_timer_timeout() -> void:
	jumpable = true
	await get_tree().create_timer(0.3).timeout
	jumpable = false
