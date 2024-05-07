extends Destructible
class_name Door

@export_enum("Regular", "Slide", "Rotate") var opening := 0
@export_enum("horizontal", "vertical") var direction := 0
@export var max_angle := deg_to_rad(90)
@export var max_move := Vector3(0,2.2,0)
@export var open_speed := 5

var start_pos := Vector3.ZERO
var start_rot := Vector3.ZERO
@export var target_position := start_pos
@export var target_rotation := start_rot
@export var opened := false

func _init():
	freeze = true

func _ready():
	start_pos = global_position
	start_rot = rotation
	target_position = global_position
	target_rotation = start_rot
	super()

func _physics_process(delta):
	if opening == 0:
		if target_rotation != rotation:
			rotation = lerp(rotation, target_rotation, open_speed*delta)
		if abs(target_rotation.distance_to(rotation)) < 0.05:
			rotation = target_rotation
	if opening == 1:
		if target_position != global_position:
			global_position = lerp(global_position, target_position, open_speed*delta)
		if abs(target_position.distance_to(global_position)) < 0.05:
			global_position = target_position
	if opening == 2 and opened:
		rotate(Vector3.UP, open_speed*delta)
		pass

func use():
	if opened:
		rpc("close")
	else:
		rpc("open")
	return super()

@rpc("any_peer","call_local","unreliable_ordered")
func open():
	if opening == 0:
		if direction == 0:
			door_rotate(start_rot + Vector3(0,max_angle,0))
		else:
			door_rotate(start_rot + Vector3(max_angle,0,0))
	elif opening == 1:
		door_move(start_pos+max_move)
		
	opened = true

@rpc("any_peer","call_local","unreliable_ordered")
func close():
	if opening == 0:
		door_rotate(start_rot)
	elif opening == 1:
		door_move(start_pos)
		
	opened = false

func door_rotate(angle):
	target_rotation = angle
	pass

func door_move(tar_pos):
	target_position = tar_pos
	pass
