extends KinematicBody
export var walk_speed = 3.0
export var run_speed = 2.0
export var bike_speed = 7.0
export var surf_speed = 0.0
export var gravity_strength = 0.8
const GRID_SIZE = 2.0
var initial_position = Vector3.ZERO
var input_direction = Vector3.ZERO
var is_moving = false
var percent_moved_to_next_grid = 0.0
var ray_length = 1.5
var sub_ray_length = 0.7
var gravity = Vector3.DOWN
var bike_mode = false
var surf_mode = false
onready var raycast = $RayCast
onready var subraycast = $SubRayCast
onready var gravityraycast = $GravityRayCast
onready var climbraycast = $ClimbRayCast
	
func _ready():
	initial_position = position
	raycast.enabled = true
	subraycast.enabled = true
	gravityraycast.enabled = true
	climbraycast.enabled = true

	
	
func _physics_process(delta):
	apply_gravity(delta)
	if is_moving:
		move(delta)
	else:
		process_player_input()
	
	
	

	



func process_player_input():
	input_direction = Vector3.ZERO

		
	
	if Input.is_action_pressed("ui_down"):
		input_direction.z += 1
		raycast.cast_to = Vector3(0, 0, 1.5)
		subraycast.cast_to = Vector3(0, 0, 1.5)
		climbraycast.cast_to = Vector3(0, -1.5, 1.5)
		raycast.force_raycast_update()
		subraycast.force_raycast_update()
		climbraycast.force_raycast_update()
		if climbraycast.is_colliding() and not raycast.is_colliding():
			var collider = climbraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y += 0.15
		if gravityraycast.is_colliding() and not climbraycast.is_colliding():
			var collider = gravityraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y -= 0.15
	elif Input.is_action_pressed("ui_up"):
		input_direction.z -= 1
		raycast.cast_to = Vector3(0, 0, -1.5)
		subraycast.cast_to = Vector3(0, 0, -1.5)
		climbraycast.cast_to = Vector3(0, -1.5, -1.5)
		raycast.force_raycast_update()
		subraycast.force_raycast_update()
		climbraycast.force_raycast_update()
		if climbraycast.is_colliding() and not raycast.is_colliding():
			var collider = climbraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y += 0.15
		if gravityraycast.is_colliding() and not climbraycast.is_colliding():
			var collider = gravityraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y -= 0.15
	elif Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
		raycast.cast_to = Vector3(-1.5, 0, 0)
		subraycast.cast_to = Vector3(-1.5, 0, 0)
		climbraycast.cast_to = Vector3(-1.5, -1.5, 0)
		raycast.force_raycast_update()
		subraycast.force_raycast_update()
		climbraycast.force_raycast_update()
		if climbraycast.is_colliding() and not raycast.is_colliding():
			var collider = climbraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y += 0.15
		if gravityraycast.is_colliding() and not climbraycast.is_colliding():
			var collider = gravityraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y -= 0.15
	elif Input.is_action_pressed("ui_right"):
		input_direction.x += 1
		raycast.cast_to = Vector3(1.5, 0, 0)
		subraycast.cast_to = Vector3(1.5, 0, 0)
		climbraycast.cast_to = Vector3(1.5, -1.5, 0)
		raycast.force_raycast_update()
		subraycast.force_raycast_update()
		climbraycast.force_raycast_update()
		if climbraycast.is_colliding() and not raycast.is_colliding():
			var collider = climbraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y += 0.15
		if gravityraycast.is_colliding() and not climbraycast.is_colliding():
			var collider = gravityraycast.get_collider()
			if collider.name == "GridMap3":
				input_direction.y -= 0.15
	
	input_direction = input_direction.normalized()  # Normalizza la direzione

	
	
	
	if input_direction != Vector3.ZERO:
		initial_position = position
		is_moving = true

		
		gravityraycast.force_raycast_update()



		
	if raycast.is_colliding() and is_moving:
		input_direction = Vector3.ZERO
		print("wall")
	if subraycast.is_colliding() and is_moving:
		var collider = subraycast.get_collider()
		if collider.name == "GridMap2" and not surf_mode:
			input_direction = Vector3.ZERO
			
	
	if Input.is_action_just_pressed("ui_y"):
		print(global_transform.origin.y)
	
	if subraycast.is_colliding():
		print("surf lock")
		var collider = subraycast.get_collider()
		if collider.name == "GridMap2" and Input.is_action_just_pressed("ui_surf") and not surf_mode and not raycast.is_colliding():
			var collision_point = subraycast.get_collision_point()
			# Allinea la posizione del giocatore al centro della cella puntata
			position.x = round(collision_point.x / GRID_SIZE) * GRID_SIZE
			position.z = round(collision_point.z / GRID_SIZE) * GRID_SIZE
			surf_mode = true
			if bike_mode:
				bike_mode = false
			print("surf mode on")
		if collider.name == "GridMap" and  surf_mode:
			input_direction = Vector3.ZERO
		if collider.name == "GridMap" and Input.is_action_just_pressed("ui_surf") and surf_mode and not raycast.is_colliding():
			var collision_point = subraycast.get_collision_point()
			# Allinea la posizione del giocatore al centro della cella puntata
			position.x = round(collision_point.x / GRID_SIZE) * GRID_SIZE
			position.z = round(collision_point.z / GRID_SIZE) * GRID_SIZE
			surf_mode = false
			print("surf mode off")

	if Input.is_action_just_pressed("ui_bike") and not surf_mode:
		bike_mode = !bike_mode
	
func apply_gravity(delta):
	gravityraycast.force_raycast_update()
	if position.y > -100 and not gravityraycast.is_colliding():  # Presupponendo che l'altezza del terreno sia 0
		position.y += gravity.y * delta * 18 # Gravitazione continua verso il basso
	else:
		var collision_point = gravityraycast.get_collision_point()
		var collider = gravityraycast.get_collider()
		position.y = collision_point.y + 0.8




	
	
func move(delta):
		percent_moved_to_next_grid += walk_speed * delta
		if percent_moved_to_next_grid >= 1.0:
			position.x = round(initial_position.x + (GRID_SIZE * input_direction.x))
			position.z = round(initial_position.z + (GRID_SIZE * input_direction.z))
			position.y = initial_position.y + (GRID_SIZE * input_direction.y)
			percent_moved_to_next_grid = 0.0
			is_moving = false
		else:
			position.x = initial_position.x + (GRID_SIZE * input_direction.x * percent_moved_to_next_grid) 
			position.z = initial_position.z + (GRID_SIZE * input_direction.z * percent_moved_to_next_grid)
			position.y = initial_position.y + (GRID_SIZE * input_direction.y * percent_moved_to_next_grid)
		if Input.is_action_pressed("ui_run") and is_moving and not bike_mode and not surf_mode:
			percent_moved_to_next_grid += run_speed * delta
		if bike_mode and is_moving:
			percent_moved_to_next_grid += bike_speed * delta
		if surf_mode and is_moving:
			percent_moved_to_next_grid += surf_speed * delta
			

