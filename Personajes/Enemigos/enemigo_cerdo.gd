extends Personajes

var direccion = -1
var canChangeDireccion = true
var player

func _ready():
	animation.play("walk")
	speed = 60

@onready var raySuelo : RayCast2D = $Raycasts/RayCastSuelo
@onready var rayMuro : RayCast2D = $Raycasts/RayCastMuro
@onready var rays = $Raycasts
@onready var rayPlayer = $RayCastPlayerDetector
@onready var animation = $AnimationPlayer

enum estados {ANGRY, PATRULLAR, MORIR}
var estadoActual = estados.PATRULLAR

func _physics_process(delta):
	velocity.x = direccion * speed
	
	if !is_on_floor():
		velocity.y += 9
	
	move_and_slide()

func _process(delta):
	
	if player == null and rayPlayer.is_colliding():
		var collision = rayPlayer.get_collider()
		if collision.is_in_group("Player"):
			player = collision
			estadoActual = estados.ANGRY
	
	if estadoActual == estados.ANGRY and player != null:
		animation.play("runAngry")
		var directionPlayer = global_position.direction_to(player.global_position)
		if directionPlayer.x < 0:
			direccion = -1
		elif directionPlayer.x > 0:
			direccion = 1
		$Sprite2D.flip_h = true if direccion == 1 else false
	
	if estadoActual == estados.PATRULLAR:
		if canChangeDireccion and (rayMuro.is_colliding() or !raySuelo.is_colliding()):
			canChangeDireccion = false
			$Raycasts/RayTimer.start()
			direccion *= -1
			rays.scale.x *= -1
		$Sprite2D.flip_h = true if direccion == 1 else false

func takeDmg(damage):
	vida -= damage
	if vida <= 0:
		$dmgPlayer/CollisionShape2D.set_deferred("disabled", true)
		estadoActual = estados.MORIR
		animation.play("hurt")
		$CollisionShape2D.set_deferred("disabled", true)
		await (animation.animation_finished)
		queue_free()

func _on_ray_timer_timeout() -> void:
	canChangeDireccion = true
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.takeDamage(dmg)
