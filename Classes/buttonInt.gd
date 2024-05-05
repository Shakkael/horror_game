extends Interactive
class_name  ButtonInt

@export_node_path("Interactive") var target_path : NodePath

func use():
	var target_node : Interactive = get_node(target_path)
	target_node.use()
	return super()
