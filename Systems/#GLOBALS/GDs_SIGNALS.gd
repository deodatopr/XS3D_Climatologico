class_name GDs_SIGNALS
extends Node

#DATA SERVICE
@warning_ignore('unused_signal')
signal OnRefresh

#SCENES
@warning_ignore('unused_signal')
signal OnGoToSitio(_idSitio : int)

@warning_ignore('unused_signal')
signal OnSitioInitialized

#CAMERA
@warning_ignore('unused_signal')
signal OnCameraUpdate(_isUpdating : bool)

@warning_ignore('unused_signal')
signal OnCameraRequestChangeMode(_modoToChange : int)

@warning_ignore('unused_signal')
signal OnCameraCanChangeMode()

@warning_ignore('unused_signal')
signal OnCameraChangedMode(_modoToChange : int)

#DEBUG
@warning_ignore('unused_signal')
signal OnDebugRefresh()
