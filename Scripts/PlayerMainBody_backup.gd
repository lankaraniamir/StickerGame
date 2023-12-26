extends CharacterBody2D

@onready var root_scene = get_tree().get_root()
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var internal_raycast = $RayCast2D
@onready var sub_bodies = $Connections.get_children()
var sub_body = preload("res://Scenes/sub_body.tscn")

@onready var radius = collision_shape.shape.get_radius()
@export var speed : float = 300
@export var rotation_speed : float = 8 * PI
@export var min_angle_change : float = PI / 4

@export var shoot_distance = 35
var bullet = preload("res://Scenes/bullet.tscn")
var fire_time = 0

@export var face_neutral = 852
@export var face_wow = 1519
@export var face_plz = 895

@export var sub_body_paths = []


func _ready():
	#add_to_group("player")
	create_adjacent_body()
	create_adjacent_body()
	create_adjacent_body()
	create_adjacent_body()

func _physics_process(delta):
	move_and_look(delta)
	constrict_bounds()
	shoot_if_input(delta)

func move_and_look(delta):
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	velocity = speed * move_dir
	
	if look_dir:
		var final_angle = atan2(look_dir.y, look_dir.x)
		var angle_change = final_angle - rotation
		if angle_change > PI:
			angle_change -= 2 * PI
		elif angle_change < -PI:
			angle_change += 2 * PI
		
		angle_change *= rotation_speed
		if angle_change > 0 and angle_change < min_angle_change:
			angle_change = min_angle_change
		elif angle_change < 0 and angle_change > min_angle_change:
			angle_change = -min_angle_change
		rotation += angle_change * delta
	
	move_and_slide()

func constrict_bounds():
	var bounds = get_viewport_rect().size
	global_position.x = wrapf(global_position.x, 0, bounds.x)
	global_position.y = wrapf(global_position.y, 0, bounds.y)

func shoot_if_input(delta):
	if Input.is_action_just_pressed("shoot"):
		fire()
		fire_time = delta
	elif fire_time:
		fire_time += delta
		if fire_time > .25:
			sprite.frame = face_plz
			fire_time = 0

func fire():
	var bullet_instance = bullet.instantiate()
	var shoot_dir = Vector2(1, 0).rotated(global_rotation)
	bullet_instance.position = get_global_position() + 35 * shoot_dir
	bullet_instance.rotation = global_rotation
	root_scene.call_deferred("add_child", bullet_instance)
	sprite.frame = face_wow
	
func create_adjacent_body():
	# consider raycasting instead
	var success = false
	var new_direction = null
	var new_position = null
	var count = 0
	#var descendants = get_child("SubBodies").get_children()
	while !success and count < 25:
		success = true
		new_direction = random_unit_vector()
		new_position = 2 * radius * new_direction
		
		for body_path in sub_body_paths:
			var body = get_node(body_path)
			if new_position.distance_to(body.position) < 2 * radius:
				success = false
				print(new_position, body.position, radius)
				break
				
		count += 1
				
	
	#var perpendicular_direction = Vector2(new_direction.y, -new_direction.x)
	#var left_check = new_position + perpendicular_direction
	#var right_check = new_position - perpendicular_direction
	#for body in sub_bodies:
		#var body_collider = body.CollisionShape2D
		#...
	if count != 25:
		var new_instance = sub_body.instantiate()
		new_instance.global_position = new_position
		new_instance.rotation = rotation_speed
		add_child(new_instance)
		sub_body_paths.append(new_instance.get_path())
	else:
		print("too many failures")
	
#func create_adjacent_body():
	## consider raycasting instead
	#var success = false
	#var new_direction = null
	#var new_position = null
	#var count = 0
	#while !success and count < 25:
		#success = true
		#new_direction = random_unit_vector()
		#new_position = 2 * radius * new_direction
		#
		#for body_path in sub_body_paths:
			#var body = get_node(body_path)
			#if new_position.distance_to(body.position) < 2 * radius:
				#success = false
				#print(new_position, body.position, radius)
				#break
				#
		#count += 1
				#
	#
	##var perpendicular_direction = Vector2(new_direction.y, -new_direction.x)
	##var left_check = new_position + perpendicular_direction
	##var right_check = new_position - perpendicular_direction
	##for body in sub_bodies:
		##var body_collider = body.CollisionShape2D
		##...
	#if count != 25:
		#var new_instance = sub_body.instantiate()
		#new_instance.global_position = new_position
		#new_instance.rotation = rotation_speed
		#add_child(new_instance)
		#sub_body_paths.append(new_instance.get_path())
	#else:
		#print("too many failures")
	#
#https://github.com/godotengine/godot/issues/34301
func random_unit_vector():
	var angle = randf() * 2 * PI
	return Vector2( sin(angle), cos(angle) )
	
