#BUG: Si estas en un modo, está perdiendo señal y te cambias se queda con UI de perdiendo señal

#TODO:
#===========================================
#	Pendientes Progra
#===========================================

#	[ Pani ]
# INPUTS:
	# Control -> Circulo centro toggle datos random y datos endpoint / F12
	# X y Y : cambiar modo camara
	# T abra menu de info
	# O Abra panel de debug
	# A - aceptar
	# B - Back

#
# Variables estacion actualizarlas y dejar solo las del uúltimo documento de endpoint
# Hay cosas con control que no están actualizadas (Y no es cambio de cam), pad para menu
# Probar sonidos que algunos aunque llegan al limite se siguen escuchando
# (idea de sonido dif cuando no puedas)
# Mouse detect musica panel

# Manager para debuggear caracteristicas
# Que sucede cuando no hay datos con mensaje de reconexión
# Tooggle: Maquina estados para diferentes casos
## Quitar de globals obtencion de navmesh
# No se queda prendido el sitio al que me voy

#Cam fly
## Forward hacia adelante en local y hacia atras en global
## Ajustar bien cuando aparece y desaparece flecha de dirección
# A cierta distancia activar el AO
# Arreglar brujula norte

## Armado flujo completo (orquestador, datos,etc)
## Minimap arreglar
## Turbo (height / rotación)

# Cambio entre sitios
# Entregar rotcion de cam fly sin ajuste de 0 a 180 en ambas direcciones
# Cambiar todo lo que diga Estaciones -> Sitios (Para estandarizar)
# contenido y sin datos: si entre 
# "Estableciendo conexión con servidor"
# "Obteniendo datos con el servidor
# Reintentar con boton
# Valores es 0 poner rayitas

# Maquina estados de datos:
	# Agregar bateria cfe booleano
	# Agregar sensor nivel booleano
	# Checar valores random que tengan sentido
	# Cuando llueve, viento random
	# minMax, minMin, medMax, medMin, maxMax, maxMin
	# Altura de presas dependiendo como se ven en la realidad de 0-80
	# AC falla CFE arriba de bateria
	# Dos señales: UTR -> enlace
	# Sensor con marca si estaactualizado o no 
	# Los valores de nivel quemado
	# Si no hay ac y no bateria no hay señales utr / telefono
	
	#Llover si o no:
		# Precipitacion/ presion/ humedad
		# Cada condicion con su max y con min
		# Evaporación y temperatura igual
		# Viento
		# Nivel 

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

# Tool para hacer match entre material y textura
