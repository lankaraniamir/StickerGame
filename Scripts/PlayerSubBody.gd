extends Area2D


@onready var root_scene = get_tree().get_root()
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
var sub_body = preload("res://Scenes/sub_body.tscn")

@onready var radius = collision_shape.shape.get_radius()
@export var shoot_distance = 35
var bullet = preload("res://Scenes/bullet.tscn")
var fire_time = 0

@export var face_neutral = 852
@export var face_wow = 1519
@export var face_plz = 895

@export var play_mode = true


#func _ready():
	#add_to_group("player")

func _physics_process(delta):
	#constrict_bounds()
	if play_mode:
		shoot_if_input(delta)

func constrict_bounds():
	var bounds = get_viewport_rect().size
	global_position.x = wrapf(global_position.x, 0, bounds.x)
	global_position.y = wrapf(global_position.y, 0, bounds.y)

func shoot_if_input(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
		fire_time = delta
	elif fire_time:
		fire_time += delta
		if fire_time > .25:
			sprite.frame = face_plz
			fire_time = 0

func shoot():
	var bullet_instance = bullet.instantiate()
	var shoot_dir = Vector2(1, 0).rotated(global_rotation)
	bullet_instance.position = get_global_position() + 35 * shoot_dir
	bullet_instance.rotation = global_rotation
	root_scene.call_deferred("add_child", bullet_instance)
	sprite.frame = face_wow
