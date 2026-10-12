class_name EmoteDef
extends Resource

# Un emote de la rueda. Los emotes se describen como datos y no como código, para que
# agregar uno nuevo sea llenar una ficha en el inspector y no tocar la rueda.

## Identificador corto que viaja por la red cuando alguien lanza este emote.
@export var id: StringName = &""

## Texto que aparece en el medallón de la rueda mientras se apunta el segmento.
@export var nombre: String = ""

## Dibujo del emote. Se usa en el segmento de la rueda y en la burbuja del gato.
@export var icono: Texture2D

## Nodo OneShot del AnimationTree del gato que reproduce la animación del emote.
## Dejarlo vacío significa que el emote solo muestra la burbuja, sin animación.
@export var animacion_oneshot: StringName = &""

## Cuántos segundos dura esa animación. Solo se usa si hay animación.
@export var animacion_duracion: float = 0.0

## Cuántos segundos queda la burbuja sobre la cabeza antes de desvanecerse.
@export var duracion_burbuja: float = 2.5


func tiene_animacion() -> bool:
	return not animacion_oneshot.is_empty() and animacion_duracion > 0.0
