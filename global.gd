extends Node

var frutas = 0 :
	set(valor):
		frutas = valor
		if player != null:
			player.actualizaInterfazFrutas()
			$frutasSonido.play()
	get:
		return frutas

var player
