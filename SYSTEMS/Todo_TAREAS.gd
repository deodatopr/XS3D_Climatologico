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
		# WASD (Mov coords local)
		# Mouse + click (Rot solo Y)
		
	#Inputs Control:
		#Gatillos der (subir/bajar)
		#Gatillos izq (modo)
		#D-Pad (UI)
		#Start menu
		#Boton der (Aceptar)
		#Joystick (mover cam)
		#Joystick (rot cam)

#MAPA
#- Sistema camara
	# movimiento con elastico, tween desacceleracion (CIRC) (Volar lento, que se sienta chido)
	# rotation para poder ver el cielo y si sueltas se regrese lerp (multiplicado por curva) o ver is con tween nos sirve (TYPE_BACK)
	# *Altura variable (temporal) con gatillos subir y bajar
	# Dos modos:
			#Rotacion inclinada (zoom en local)
			#Rotacion viendo suelo (zoom local)
	# Si va navegando y detectar si hay montaña para subir o bajar la camara y no colisione o traspase
		#Idea: ColisionArea3d lanzar rayo y subir camara
	# bounding
	# focus en un punto
#- Minimapa (con icono como camara con angulo de vista)
	# Que se expanda/minimize al presionarlo
	# Si presionas un punto en el mapa te lleve ahí
	# Icono de camara en minimapa para saber donde estas y hacia a donde miras
#- Brujula en mapa
	# Ref Brujula horizon: Al rotar te indique en donde hay presas
#- Sistema Pines
	#Para lagunas
	#Para lugares medio iconicos (personalizar color, icono, nombre)
#- Menu con todas las estaciones para ir al mapa seleccionandola desde UI
#- Debug Perf/Mapa
#- Aparece presa en mapa, le das click y te salé UI (como google maps) con info de la presa

#PARTICULARES (Detenido de momento)
#- Crear escena de particulares para tener base de flujo completo
#- Orquestador particulares
#- MngParticulares
