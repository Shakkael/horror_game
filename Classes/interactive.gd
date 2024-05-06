extends RigidBody3D
class_name Interactive

@export var usable := true
@export_group("Model")
@export var model_mesh : Mesh
@export var interactive : Material = preload("res://Materials/interactive.tres")
@export var target : Texture = preload("res://Graphics/Sprites/HUD/Placeholder.png")
@export_group("Interaction")
@export var hit_particles : CPUParticles3D
@export var action_sounds : Array[AudioStream] = [preload("res://SFX/Uses/sfxUnusable.wav")]
@export_flags("Start Playing") var on_ready := 0
@export_flags("Stop") var if_stopped_using := 0
@export_enum("One-Way","Two-Way","Reverse") var when_played := 0
@export var use_sounds : Array[AudioStream] = [preload("res://SFX/Uses/sfxUsable.wav")]
@export var damage_sounds : Array[AudioStream] = [preload("res://SFX/Uses/Damage/sfxDamage.wav")]
#@export var walk_sound String?

var InstanceMesh = MeshInstance3D.new()
var OutlineMesh = MeshInstance3D.new()
var ActionPlayer = AudioStreamPlayer3D.new()
var DamagePlayer = AudioStreamPlayer3D.new()
var DamageTimer = Timer.new()

@export var been_used := false
var last_collided_body = null

func _init():
	DamageTimer.wait_time = 0.25
	DamageTimer.connect("timeout",collision_refresh)
	can_sleep = false
	contact_monitor = true
	max_contacts_reported = 1
	continuous_cd = true

func _ready():
	InstanceMesh.mesh = model_mesh
	InstanceMesh.material_overlay = interactive.duplicate()
	InstanceMesh.material_overlay.set("shader_parameter/blink",false)
	
	var mesh = InstanceMesh.mesh
	var outline = mesh.create_outline(0.05)
	var Collision = CollisionShape3D.new()
	Collision.shape = mesh.create_convex_shape()
	OutlineMesh.mesh = outline
	OutlineMesh.set_surface_override_material(0,preload("res://Materials/outline.tres").duplicate())
	
	ActionPlayer.stream = action_sounds.pick_random()
	DamagePlayer.stream = damage_sounds.pick_random()
	
	add_child(InstanceMesh)
	add_child(Collision)
	add_child(OutlineMesh)
	add_child(ActionPlayer)
	add_child(DamagePlayer)
	
	if on_ready:
		ActionPlayer.play()

func _physics_process(_delta):
	physics_hit()

func physics_hit():
	if get_contact_count() > 0 and abs(linear_velocity) > Vector3(0.1,0.1,0.1):
		var vel = 0
		for body in get_colliding_bodies():
			var collision_normal = global_position.direction_to(body.global_position).normalized()
			vel = linear_velocity.x*collision_normal.x + \
			linear_velocity.y*collision_normal.y + linear_velocity.z*collision_normal.z
			if abs(vel) > 0.2 and body != last_collided_body:
				DamagePlayer.play()
				last_collided_body = body

func looked_at():
	InstanceMesh.material_overlay.set("shader_parameter/blink",true)
	OutlineMesh.get_surface_override_material(0).set("shader_parameter/blink",true)

func not_looked_at():
	InstanceMesh.material_overlay.set("shader_parameter/blink",false)
	OutlineMesh.get_surface_override_material(0).set("shader_parameter/blink",false)

func use():
	rpc("_use")

@rpc("any_peer","call_local","unreliable_ordered")
func _use():
	randomize()
	play_sound()
	been_used = !been_used
	return use_sounds.pick_random()

func play_sound():
	if when_played == 0:
		if !been_used:
			ActionPlayer.play()
		else:
			if if_stopped_using:
				ActionPlayer.stop()
	elif when_played == 1:
		ActionPlayer.play()

func collision_refresh():
	last_collided_body = null
