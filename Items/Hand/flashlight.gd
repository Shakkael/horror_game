extends Pickable

func use():
	$Lamp/SpotLight3D.visible = !$Lamp/SpotLight3D.visible
	return super()

func in_hand():
	$Lamp.layers = 32
	super()
