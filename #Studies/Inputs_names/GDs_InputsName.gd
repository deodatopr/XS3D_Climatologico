extends Node

func _ready():
	# Recorremos los posibles joysticks (hasta 8 controladores soportados en este caso)
	for device_id in range(8):
		if Input.is_joy_known(device_id):
			var controller_name = Input.get_joy_name(device_id)
			print("Controller connected: ", controller_name)

			# Puedes hacer comparaciones con nombres conocidos
			if controller_name.find("Xbox") != -1:
				print("It's an Xbox controller!")
			elif controller_name.find("PlayStation") != -1:
				print("It's a PlayStation controller!")
			elif controller_name.find("Nintendo") != -1:
				print("It's a Nintendo controller!")
			else:
				print("Unknown controller type.")
