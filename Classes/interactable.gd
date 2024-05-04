extends RigidBody3D
class_name Interactive

@export var usable := true
@export_group("Model")
@export var model_mesh : Mesh
@export var interactive : Material = preload("res://Materials/interactive.tres")
@export var model_material : Material
@export var target : Texture = preload("res://Graphics/Sprites/HUD/Placeholder.png")

var InstanceMesh = MeshInstance3D.new()
var OutlineMesh = MeshInstance3D.new()


func _init():
	can_sleep = false

func _ready():
	InstanceMesh.mesh = model_mesh
	
	InstanceMesh.material_overlay = model_material.duplicate()
	InstanceMesh.material_override = interactive.duplicate()
	InstanceMesh.material_override.set("shader_parameter/blink",false)
	
	var mesh = InstanceMesh.mesh
	var outline = mesh.create_outline(0.05)
	var Collision = CollisionShape3D.new()
	Collision.shape = mesh.create_convex_shape()
	OutlineMesh.mesh = outline
	OutlineMesh.set_surface_override_material(0,preload("res://Materials/outline.tres").duplicate())
	
	add_child(InstanceMesh)
	add_child(Collision)
	add_child(OutlineMesh)

func looked_at():
	InstanceMesh.material_override.set("shader_parameter/blink",true)
	OutlineMesh.get_surface_override_material(0).set("shader_parameter/blink",true)

func not_looked_at():
	InstanceMesh.material_override.set("shader_parameter/blink",false)
	OutlineMesh.get_surface_override_material(0).set("shader_parameter/blink",false)
