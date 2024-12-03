class_name GDs_SIGNALS
extends Node

#DATA SERVICE
@warning_ignore('unused_signal')
signal OnRefresh
@warning_ignore('unused_signal')
signal OnRequestResult_Success
@warning_ignore('unused_signal')
signal OnRequestResult_Error_NoData
@warning_ignore('unused_signal')
signal OnRequestResult_Error_Data
@warning_ignore('unused_signal')
signal OnRequestResult_Hist_Success
@warning_ignore('unused_signal')
signal OnRequestResult_Hist_Error

#SCENES
@warning_ignore('unused_signal')
signal OnGoToSitio(_idSitio : int)
@warning_ignore('unused_signal')
signal OnSectorLoaded
@warning_ignore('unused_signal')
signal OnSitioReady

#CLIMATOLOGIA
@warning_ignore('unused_signal')
signal OnLluviaSet(_lluvia : int)

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
@warning_ignore('unused_signal')
signal OnDatosSimuladosON
@warning_ignore('unused_signal')
signal OnDatosSimuladosOFF
