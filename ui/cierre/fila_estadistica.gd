class_name FilaEstadistica
extends Control

# Una línea del resumen de la jornada: un dibujo a la izquierda, de qué se trata y
# cuánto fue. Existe como escena aparte para que el panel de cierre no repita tres veces
# los mismos nodos y para que agregar una cuarta estadística sea sumar una instancia.

@onready var dibujo: TextureRect = %Dibujo
@onready var etiqueta: Label = %Etiqueta
@onready var valor: Label = %Valor


func mostrar(icono: Texture2D, texto: String, cantidad: int) -> void:
	dibujo.texture = icono
	etiqueta.text = texto
	valor.text = str(cantidad)
