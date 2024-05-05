extends Pickable

@export var working := true

func _ready():
	on_ready = working
	ActionPlayer.volume_db = -40
	been_used = working
	$Lamp/SpotLight3D.visible = working
	super()

func use():
	$Lamp/SpotLight3D.visible = !$Lamp/SpotLight3D.visible
	return super()

func in_hand():
	$Lamp.layers = 32
	super()
