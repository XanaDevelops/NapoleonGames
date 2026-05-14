# Logica de juego implementada

Este documento describe, por acción, qué atributos se tienen en cuenta y cuáles no según la lógica actual.

## Acciones de mapa y casillas

### Acción: construir mapa jugable (MapRes -> MapGame)
- Se tiene en cuenta: `mapData` como grilla; cada `TileRes` crea un `TileGame` con posición `Vector2i(x,y)`.
- No se tiene en cuenta: `desc` del mapa, validación de `tamX/tamY` contra el contenido real.

### Acción: obtener vecinos de una casilla
- Se tiene en cuenta: layout hexagonal con offset horizontal por filas (paridad en `y`).
- No se tiene en cuenta: coste o bloqueos; solo límites de mapa.

## Acciones de movimiento y alcance

### Acción: calcular casillas accesibles (Dijkstra)
- Se tiene en cuenta: coste de terreno por tipo de carta, penalización por altura, velocidad de la unidad.
- No se tiene en cuenta: unidades bloqueando el camino (solo filtra la casilla final si está ocupada).

### Acción: mover unidad
- Se tiene en cuenta: casilla origen debe tener unidad, destino debe estar libre.
- No se tiene en cuenta: alcanzabilidad por coste o ruta válida.

### Acción: casillas en rango (BFS)
- Se tiene en cuenta: radio en número de pasos, excluye la casilla origen.
- No se tiene en cuenta: coste de terreno ni unidades en medio.

## Acciones de despliegue

### Acción: calcular grupo de despliegue
- Se tiene en cuenta: altura de zona de despliegue (`deployHeight`), BFS por vecinos, límites de mapa, casillas libres.
- No se tiene en cuenta: coste de terreno, altura, o restricciones adicionales.

### Acción: desplegar unidades desde carta
- Se tiene en cuenta: tamaño del grupo, propietario, casillas calculadas, registro de acción.
- No se tiene en cuenta: coste de maná o recursos de despliegue.

## Acciones de turno y fases

### Acción: avanzar turno
- Se tiene en cuenta: orden fijo entre dos jugadores, emite `tick_turn`.
- No se tiene en cuenta: iniciativa, velocidad global o efectos de prioridad.

### Acción: reinicio de flags por turno (unidad)
- Se tiene en cuenta: resetea `has_moved_this_turn` y `has_used_hability_this_turn`.
- No se tiene en cuenta: acciones pendientes por IA o colas de acciones.

## Acciones de habilidades y combate

### Cobertura de estadísticas en habilidades
- Se tiene en cuenta: `ATTACK` aplica daño directo; `HEALTH` cura; `SPEED` afecta movimiento; `DEFENSE` afecta reducción de daño; `DODGE` interviene en impactos; `MANA` solo como coste.
- No se tiene en cuenta: `HEIGHT` no se modifica por habilidades.
- No se tiene en cuenta: `MAX_HEALTH`/`MAX_MANA` como cambios directos (bloqueados en la lógica actual).

### Condiciones de habilidades: estadísticas y definición esperada
- Se tiene en cuenta: `condition`, `condition_stat`, `condition_value` en `HabilityRes`.
- Se espera: `condition != NA` y `condition_stat != null` para evaluar la condición.
- Se evalúa: `current_value = get(condition_stat.name)` en la unidad, y se compara con `condition_value` (LT/LE/GT/GE/EQ/NE).
- Si `condition_stat.isPercent` es `true`, se espera que el `name` empiece por `max_` (p. ej. `max_health`, `max_mana`).
- En porcentaje: se calcula `get(name.trim_prefix("max_")) / get(name)` y se compara con `condition_value`.
- No se tiene en cuenta: condiciones basadas en terreno o estados externos a la unidad.

### Acción: determinar habilidades disponibles
- Se tiene en cuenta: cooldown, maná, condición de estadística, existencia de objetivos en rango.
- No se tiene en cuenta: línea de visión, bloqueo por terreno, o inmunidades no definidas.

### Acción: usar habilidad activa
- Se tiene en cuenta: turno del propietario, no haber usado habilidad activa ese turno, cooldown, maná, condiciones; aplica efectos y estados alterados.
- No se tiene en cuenta: restricciones de línea de visión o coste de oportunidad adicional.

### Acción: ejecutar pasivas
- Se tiene en cuenta: se disparan al principio del turno propio, usan la misma lógica de habilidades.
- No se tiene en cuenta: reacciones a eventos.

### Acción: aplicar estados alterados
- Se tiene en cuenta: duración, probabilidad por tick, objetivo, estadística y tipo de ataque.
- No se tiene en cuenta: acumulación múltiple del mismo estado (se reemplaza por clave en diccionario).

### Acción: recibir daño
- Se tiene en cuenta: defensa por tipo de ataque, modificadores por estados alterados, daño mínimo 0 y esquiva (`dodge`).
- No se tiene en cuenta: críticos.

### Acción: curar
- Se tiene en cuenta: curación plana o porcentual sobre vida máxima.
- No se tiene en cuenta: overheal como escudo.
- Nota: si se quiere daño verdadero pero esquivable, usar un tipo de ataque específico en vez de curar negativo.
- Nota: falta implementar el llamado a `kill()` si al curar la unidad muere.

## Acciones de final de partida

### Acción: muerte de unidad
- Se tiene en cuenta: desconecta del turno, limpia casilla, emite señal `died`.
- No se tiene en cuenta: drops, experiencia o recompensas.

### Acción: comprobar fin de partida
- Se tiene en cuenta: conteo de unidades vivas por jugador y victoria por aniquilación.
- No se tiene en cuenta: objetivos alternativos (captura, turnos máximos, puntos).
- No se contempla otro final, por ahora, que no sea por aniquilación.
