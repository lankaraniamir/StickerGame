extends CharacterBody2D

@onready var root_scene = get_tree().get_root()
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

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

@onready var sub_bodies_container = $SubBodies
@onready var sub_bodies = get_sub_bodies()
var sub_body = preload("res://Scenes/sub_body.tscn")

@onready var insert_cursor = $InsertCursor
@export var insert_cursor_angle = 0
@export var play_mode = true
var insert_cursor_rotation_offset = -90


func _ready():
	#pass
	#add_to_group("player")
	insert_cursor_rotation_offset = sprite.rotation
	insert_cursor.rotation = insert_cursor_rotation_offset
	for i in range(10):
		create_random_adjacent_body()
	reset_cursor()


func _physics_process(delta):
	if play_mode:
		move_and_look(delta)
		constrict_bounds()
		shoot_if_input(delta)
		if (Input.is_action_just_pressed("add_random_node")):
			create_random_adjacent_body()
	else:
		move_insert_cursor(delta)
		if (Input.is_action_just_pressed("shoot") 
				or Input.is_action_just_pressed("add_random_node")):
			create_body_at_cursor()

	if (Input.is_action_just_pressed("switch_mode")):
		switch_mode()

func move_and_look(delta):
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	var change_speed = 1
	if (Input.is_action_pressed("slow_input")):
		change_speed = .25
	velocity = speed * move_dir * change_speed
	
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

func create_random_adjacent_body():
	var new_direction = random_unit_vector()
	#var new_direction =  Vector2(cos(insert_cursor_angle), sin(insert_cursor_angle))
	var new_position = find_insertion_position_in_direction(new_direction)

	var new_instance = sub_body.instantiate()
	new_instance.position = new_position
	new_instance.name = "SubBody" + str(len(sub_bodies)+1)
	new_instance.play_mode = play_mode
	sub_bodies_container.add_child(new_instance)

func move_insert_cursor(delta):
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	# implemented
	var angle_change_amount = move_dir.x
	var rotation_change_amount = look_dir.x
	
	# TODO: Implement
	var distance_change_amount = move_dir.y
	var size_change_amount = look_dir.y

	var change_speed = 1
	if (Input.is_action_pressed("slow_input")):
		change_speed = .25
	insert_cursor_angle += PI/2 * angle_change_amount * delta * change_speed
	insert_cursor.rotation += PI * rotation_change_amount * delta * change_speed
	place_cursor()

func place_cursor():
	#if play_mode:
		#reset_cursor()
	#else:
	var new_direction = Vector2(cos(insert_cursor_angle), sin(insert_cursor_angle))
	insert_cursor.position = find_insertion_position_in_direction(new_direction)

func reset_cursor():
	insert_cursor.position = position
	
func create_body_at_cursor():
	var new_instance = sub_body.instantiate()
	new_instance.position = insert_cursor.position
	new_instance.rotation = insert_cursor.rotation - insert_cursor_rotation_offset
	new_instance.name = "SubBody" + str(len(sub_bodies)+1)
	new_instance.play_mode = play_mode
	sub_bodies_container.add_child(new_instance)



func get_sub_bodies():
	return sub_bodies_container.get_children()

#https://github.com/godotengine/godot/issues/34301
func random_unit_vector():
	var angle = randf() * 2 * PI
	return Vector2( sin(angle), cos(angle) )

#func find_nearest_edge_in_direction(unit_direction, sub_bodies):
func find_insertion_position_in_direction(unit_direction):
	sub_bodies = get_sub_bodies()
	
	var successful = false
	var test_position = 2.01 * radius * unit_direction
	while(not successful):
		successful = true
		for body in (sub_bodies + [self]):
			if body.position.distance_to(test_position) < 2.01 * radius:
				successful = false
				test_position += radius * unit_direction
				break
				print('here')
	
	var external_position = test_position
	var closest_position = Vector2(0, 0)
	var closest_distance =  closest_position.distance_to(external_position)
	for body in sub_bodies:
		var body_position = body.position
		var body_distance = body_position.distance_to(external_position)
		if body_distance < closest_distance:
			closest_position = body_position
			closest_distance = body_distance
	
	var attach_direction = (external_position - closest_position).normalized()
	var new_position = 2.01 * radius * attach_direction + closest_position

	return new_position

func switch_mode():
	sub_bodies = get_sub_bodies()
	insert_cursor.rotation = insert_cursor_rotation_offset
	play_mode = not play_mode
	insert_cursor.visible = not insert_cursor.visible
	for body in sub_bodies:
		body.play_mode = play_mode
	place_cursor()
