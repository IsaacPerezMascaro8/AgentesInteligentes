# Práctica 2 — Agentes Inteligentes (pyGomas)

## Equipo: ALLIED (Team 100)

### Composición (10 unidades)
- **6 Soldados** (`MyBDISoldier`) — Clase Python custom con acción interna
- **2 Médicos** (`BDIMedic`) — Curación reactiva bajo demanda
- **2 FieldOps** (`BDIFieldOp`) — Suministro coordinado de munición

---

## Criterios implementados

### 1. Coordinación vía mensajes (30%)
- **`.send(Agent, tell, enemy_alert(Pos))`** — Broadcast de posiciones enemigas
- **`.send(Agent, achieve, escort_to(Base))`** — Petición de escolta al capturar bandera
- **Protocolo Contract Net (CFP/Propose/Accept)** — Petición de curación urgente: El soldado pide propuestas (`cfp(heal)`), y el médico más cercano gana la subasta.
- **`.send(Agent, tell, ammo_available(Pos))`** — FieldOp notifica munición disponible

### 2. Servicios nuevos (30%)
- Soldados registran servicio **"intel"** con `.register_service("intel")`
- Médicos y FieldOps consultan el servicio con `.get_service("intel")`

### 3. Comportamientos mejorados (20%)
- **Anti-friendly-fire**: Plan `!safe_shoot` evalúa amenaza antes de disparar
- **Médico reactivo**: Responde a `+!heal_soldier(Pos)` de compañeros heridos
- **FieldOp coordinado**: Notifica posición con munición a soldados

### 4. Acción interna en Python (20%)
- **`my_soldier.py`** → `MyBDISoldier` con `.calculate_threat_level(MyPos, EnemyPos, Threat)`
- Evalúa distancia, salud y munición → retorna valor 0-100

---

## Ejecución

```bash
# Terminal 1: pyJabber
conda activate pyjabber
pyjabber

# Terminal 2: Manager
conda activate pygomas
pygomas manager -j m_RodrigoIsaac@localhost -sj s_RodrigoIsaac@localhost -np 20

# Terminal 2: Manager (mapas disponibles)
# map_01 map_02 map_03 map_04 map_07 map_08 map_09 map_10 map_11 map_12 map_arena
# mine mine_medium mine_large

# Terminal 2: Manager (ejemplos de mapas)
pygomas manager -j m_RodrigoIsaac@localhost -sj s_RodrigoIsaac@localhost -np 20 -m map_03
pygomas manager -j m_RodrigoIsaac@localhost -sj s_RodrigoIsaac@localhost -np 20 -m map_04
pygomas manager -j m_RodrigoIsaac@localhost -sj s_RodrigoIsaac@localhost -np 20 -m mine_medium

# Terminal 3: Render
conda activate pygomas
pygomas render

# Terminal 4: Run
conda activate pygomas
cd ~/Agentes_Inteligentes/Practicas/AIN_ws/Practica_2
pygomas run -g pygomas_local.json
```

## Archivos
| Archivo | Descripción |
|---------|-------------|
| `bdisoldier.asl` | Lógica BDI del soldado (ataque coordinado, mensajes, anti-FF) |
| `bdimedic.asl` | Lógica BDI del médico (curación reactiva, mensajes) |
| `bdifieldop.asl` | Lógica BDI del FieldOp (suministro coordinado, mensajes) |
| `my_soldier.py` | Clase Python custom con acción interna |
| `pygomas_local.json` | Configuración de la partida |
