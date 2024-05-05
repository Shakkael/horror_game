@tool
extends EditorNode3DGizmoPlugin

var ARRAY_TANGENT : Array

func _get_name():
	return "Interactive"
func _get_gizmo_name():
	return "Interactive"

func _has_gizmo(for_node_3d):
	return for_node_3d is Interactive

func _redraw(gizmo):
	gizmo.clear()
	
	var node3d  = gizmo.get_node_3d()
	
	var mesh : Mesh = node3d.model_mesh
	var surfaces = mesh.get_surface_count()
	for i in range(0, surfaces):
		var material : Material = mesh.surface_get_material(i)
		
		var lines = mesh.get_faces()
		var handles = mesh.get_faces()
			
		gizmo.add_mesh(mesh, material)
		gizmo.add_handles(handles, material, [])
