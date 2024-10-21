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
		# Mouse Scroll UP = subir+
		# Mouse Scroll DOWN = bajar-
		# TAB = Cambio modo cam
		# Mouse + click (Rot Horizontal)
		 # SHIFT IZQ = Acelerar

	#Inputs Control:
		#Gatillos der (adelante) = Subir
		#Gatillos der (atras) = bajar
		#Gatillos izq (adelante) = Acelerar
		#Gatillos izq (atras) =  Acelerar
		#Boton der = Cancelar
		#Boton abajo = Confirmar
		#Boton arriba = Cambio modo cam
		#Joystick izq = Movimiento cam
		
	#Movimientos separados (solo uno a la vez)
		#Joystick der hor = cam rot hor
		

#MAPA
# Sistema camara
	# -- movimiento con elastico, tween desacceleracion (CIRC) (Volar lento, que se sienta chido)
	# -- *Altura variable (temporal) con gatillos subir y bajar
	# Solo dos modos
		# FOV Cam bottom: 35mm (45°) (3400) - 7000
		# FOV Cam top: 60mm
	# -- Bounding del mapa simple con x+- y z+- limite,  Usar navmesh para ese approach y nos daria la altura de montañas
	# Si va navegando y detectar si hay montaña para subir o bajar la camara y no colisione o traspase
		#Idea: ColisionArea3d lanzar rayo y subir camara
	#Rotar con pivote como si estuviera al centro y mostrar un plano del centro
		#aparecer .25
		#desaparecer .5
	# Focus en un punto usando tween (cambio de cámara o la misma pero ir con transición ahí)
	
# Brujula en mapa
	# -- 1: Brujula volando en bottom (ref horizon)
	# -- 2: Brujula volando en top (ref overwatch)
	
	
# Sistema Pines
	#--Para lagunas (Pin3D)
	#--Para lugares medio iconicos (personalizar color, icono, nombre) (Pin2D)

# MiniMapa
	# Abajo a la derecha este el minimapa (anim in/out)
	# Distancia al sitio
	# Dirección de la cámara

# Mapa
	# mapa grande  con flechas moverte entre sitios
	# Si presionas un punto en el mapa te lleve ahí

# UI Animada: Cuando pase mouse animar

# Menu con todas las estaciones para ir al mapa seleccionandola desde UI y te lleve ahi hasta que se cierre ventana
# Aparece presa en mapa, le das click y te salé UI (como google maps) con info de la presa

#PARTICULARES (Detenido de momento)
#- Crear escena de particulares para tener base de flujo completo
#- Orquestador particulares
#- MngParticulares

#Extras
#Traducir los grados en la dirección del viento (ej. 90 = N, 45 = E)

#CAMBIOS:
#Abrir por primera vez guia de input y opcion para ya no mostrar
#Con boton menos 
#Parpadear opcion de menu guia
#Tutorial guiado cuando aparece home (primero como que se presiona home y luego se prenda guia)
#Boton home abre laúltima opcion en la que te quedaste
#Eliminar pivot dist (meter de momento en proccess para ver a cuanto)

# (pivot dist) -> distance focus / camera height / bool para activar o desactivar dinamico. Juntar con altura

# - Velocidad rot
# - --Fix distancia de brujula arriba
# - --Cambio minimapa de textura grid
# - Arreglar textura 
# - Tiempo al subir es lento, usar misma curva
# - --Mini mapa aparece desaparece
# - Cambiar nombre Inclination -> Tilt
# - Rot en crudo sin acceleración
# - Quitar propiedades rot
# - Noimbre dist from pivot -> pivot dist
# - Panning -> Movement
# - Movement acceleration -> acceleration quitar max acceleration 
# - Misma curva

#Colores de sitios

# Armado flujo completo (orquestador, datos,etc)
# Cambio entre sitios
# Detalles navMesh:
# hay dos meshes el plano y otro arriba
# Modo camara 1 (dron):
#	Como lo que tenemos con parámetros y jugar con FOV, Focus, height
# Modo cámara 2 (modo libre):
#	Como camara libre del godot
# Sonidos Dron 
# Random  noise clouds shadows
# Ver el sistema de audio del godot

#Camara dron
# Fov gatillos (80 - 120)
# Height min 30
# Fov tansition / min - max y lerp
# Rotation en su posicion camara
# tansition / min - max  igual con aim
# rotar rango de abajo y al otro lado (limitado a que nunca se )

# Rot vertical limitado
# 
