class_name EmoteSet
extends Resource

# La lista ordenada de emotes que llena la rueda. El primero queda arriba y el resto
# sigue en sentido horario, igual que los sprites del kit. El largo de la lista decide
# qué rueda se dibuja, así que agregar o quitar emotes basta para cambiar la rueda.

# Tamaños de rueda que existen como sprite en res://assets/ui/rueda_emotes.
const TAMANOS_DISPONIBLES: Array[int] = [4, 6, 8]

## Los emotes de la rueda, en el orden en que se reparten los segmentos.
@export var emotes: Array[EmoteDef] = []


# Elige la rueda más chica donde quepan todos los emotes de la lista. Si sobran
# segmentos quedan vacíos, y si la lista se pasa del máximo se usa la rueda más grande.
func cantidad_segmentos() -> int:
	for tamano: int in TAMANOS_DISPONIBLES:
		if emotes.size() <= tamano:
			return tamano
	return TAMANOS_DISPONIBLES[TAMANOS_DISPONIBLES.size() - 1]


func obtener(indice: int) -> EmoteDef:
	if indice < 0 or indice >= emotes.size():
		return null
	return emotes[indice]


func buscar_por_id(id: StringName) -> EmoteDef:
	for emote: EmoteDef in emotes:
		if emote and emote.id == id:
			return emote
	return null
