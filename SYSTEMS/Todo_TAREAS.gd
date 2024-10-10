#TODO:

#===========================================
#	BASE DE LA APP
#===========================================

#- Endpoint graficadora

#===========================================
#	PARA DESPUES DE TENER LA BASE DE LA APP
#===========================================

#General
#- Sistema de inputs (será con teclado y con control)
	# Botones para 3D
	# Botones para UI
	
	#Inputs PC:
		# WASD (Mov)
		# Mouse Scroll UP = zoom +
		# Mouse Scroll DOWN = zoom -
		# 1 = modo cam Bottom
		# 2 = modo cam Top
		# Mouse + click (Rot)
		
	#Inputs Control:
		#Gatillos der (adelante) = subir
		#Gatillos der (atras) = bajar
		#Gatillos izq (adelante) = modo cam Top
		#Gatillos izq (atras) = modo cam Bottom
		#Boton der = cancelar
		#Boton abajo = confirmar
		#Joystick izq = paneo cam
		
	#Movimientos separados (solo uno a la vez)
		#Joystick der Vert = cam rot vert 
		#Joystick der hor = cam rot hor
		

#MAPA
#- Sistema camara
	# movimiento con elastico, tween desacceleracion (CIRC) (Volar lento, que se sienta chido)
	# rotation para poder ver el cielo y si sueltas se regrese lerp (multiplicado por curva) o ver is con tween nos sirve (TYPE_BACK)
	# *Altura variable (temporal) con gatillos subir y bajar
	# Dos modos:
			#Rotacion inclinada (zoom en local) tweenw diferente zoom
			#Rotacion viendo suelo (zoom local) tweenw  diferente zoom
	# Si va navegando y detectar si hay montaña para subir o bajar la camara y no colisione o traspase
		#Idea: ColisionArea3d lanzar rayo y subir camara
	# bounding del mapa simple con x+- y z+- limite,  Usar navmesh para ese approach y nos daria la altura de montañas
	# spring arm para subir la altura de la cámara
	# focus en un punto
	
	#TODO CAM:
	# Focus en un punto
	# Tween camara
	# Cam abajo: 80-90mm
	# Cam abajo: 60mm
	# Rotacion abajo mas hacia abajo
	# Toogle 
	# Camaras apretar y te vas ahí
	
	# UI Animada
	# Cuando pase mouse animar
	
#- Minimapa (con icono como camara con angulo de vista)
	# Que se expanda/minimize al presionarlo (solo salga grande)
	# Si presionas un punto en el mapa te lleve ahí
	# Icono de camara en minimapa para saber donde estas y hacia a donde miras
	
	#NUEVO AJUSTE: Mini mapa chico en una esquina y con flechas moverte entre sitios
# 1 - Brujula en mapa
	# Ref Brujula horizon: Al rotar te indique en donde hay presas
#- Sistema Pines
	#Para lagunas
	#Para lugares medio iconicos (personalizar color, icono, nombre)
#2 - Menu con todas las estaciones para ir al mapa seleccionandola desde UI y te lñleve ahi hasta que se cierre ventana
#- UI Camsra zoom
#- Aparece presa en mapa, le das click y te salé UI (como google maps) con info de la presa


#PARTICULARES (Detenido de momento)
#- Crear escena de particulares para tener base de flujo completo
#- Orquestador particulares
#- MngParticulares

#Extras
#Traducir los grados en la dirección del viento

#UI
#Lista
#Mapa
