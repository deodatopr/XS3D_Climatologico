#BUG: Si estas en un modo, está perdiendo señal y te cambias se queda con UI de perdiendo señal

#TODO:
#===========================================
#	Pendientes Progra
#===========================================

#	[ Pani ]
## Quitar de globals obtencion de navmesh

#Cam fly
## Forward hacia adelante en local y hacia atras en global
## Ajustar bien cuando aparece y desaparece flecha de dirección
# A cierta distancia activar el AO
# Arreglar brujula norte

# Armado flujo completo (orquestador, datos,etc)
# Cambio entre sitios
# Entregar rotcion de cam fly sin ajuste de 0 a 180 en ambas direcciones
# Turbo (height / rotación)

# Checar valores random que tengan sentido
# Cuando llueve, viento random
# minMax, minMin, medMax, medMin, maxMax, maxMin

#	[ Carlos ]
# Graficadora
	#Endpoint
		# Revisar endpoint para saber que datos llegan
		# Crear clase para vaciar los datos
		# Script para hacer el request con los parametros
		# Script de debug que inyecte valores random para probar UI en lo que se tiene el endpoint final
	
		#Nota:
			#Solución cuando faltan datos (Ej. Si deben de llegar 12 valores, verificar si no están todos poner en el indice que falten un valor 0)
			#Solución por si falta hora corroborar la anterior y determinar cual es la siguiente hora que corresponde de la gráfica
		
	#UI
		# Ver componentes line2D y polygon2D para graficar
		# Armar UI de gráfica (cerrar y abrir)
			#Pantalla de loading antes de que muestre los datos
			#Pantalla de error con endpoint
			#Pantalla de no hay historicos (si llegó respuesta del endpoint pero no llegaron datos)
		# Script UI para inyectar los datos y manejar las diferentes pantallas antes mencionadas


# ----------------------- Tareas:
# Track de punto 2d, al acercarte salgan unos puntos que indiquen donde está la estación
# Cambiar de uno a otro el sky

# Mapa 2D grande
	# mapa grande  con flechas moverte entre sitios
	# Si presionas un punto en el mapa te lleve ahí

# Random  noise clouds shadows

# Parpadear opcion de menu guia
# Tutorial guiado cuando aparece home (primero como que se presiona home y luego se prenda guia)
# Endpoint graficadora

#===========================================
#	Pendientes extra
#===========================================

#	Traducir los grados en la dirección del viento (ej. 90 = N, 45 = E)
#	Tomar screenshots
