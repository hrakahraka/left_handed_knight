extends CharacterBody2D

signal killed(xp_gain)


@export var speed = 200
@export var damage_value = 1
@export var HP_points = 3
@export var gravity = 1500
@export var knockback_power = 450
@export var xp_gain = 50

var player = null
var body = null
var player_pos = Vector2.ZERO
var dead = false
var player_detected = false
var direction = Vector2.ZERO
var knocked_back = false
var knockback_friction = 6.0
var death_animation_played = false


func _ready() -> void:
	add_to_group("Enemies")
	player = get_tree().get_nodes_in_group("player")[0]
	if player:
		connect("killed", Callable(player, "_on_enemy_died"))
	$AnimationTree.get("parameters/playback").travel("Idle")

func _physics_process(delta: float) -> void:
	if not dead:
		if player_detected and not knocked_back:
			player_pos = player.global_position
			direction = (player_pos - global_position).normalized()
			velocity = direction * speed
		if knocked_back:
			velocity = velocity.move_toward(Vector2.ZERO , knockback_friction )
	if HP_points <= 0 and (not death_animation_played):
		dead = true
		velocity = Vector2.ZERO
		$hurtbox/CollisionShape2D.disabled = true
		$AnimationTree.get("parameters/playback").travel("death")
		death_animation_played = true
		emit_signal("killed", xp_gain)
	move_and_slide()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not dead:
		player_pos = player.global_position
		HP_points -= player.damage_value
		knockback()
		


func _on_vision_cone_area_entered(area: Area2D) -> void:
	if not dead:
		body = area.owner
		if body != null and body.is_in_group("player"):
			player_detected = true


func _on_knock_back_timer_timeout() -> void:
	knocked_back = false


func knockback():
	knocked_back = true
	if player_pos.x < global_position.x:
		velocity.x += 500
		velocity.y += -200
	else:
		velocity.x += -500
		velocity.y += -200
	$KnockBackTimer.start()
