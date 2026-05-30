import math
from pygomas.bdisoldier import BDISoldier
from pygomas.bdimedic import BDIMedic
from pygomas.bdifieldop import BDIFieldOp
from pygomas.ontology import BACKUP_SERVICE

# =============================================================
# Funciones auxiliares compartidas
# =============================================================

def calcular_mas_cercano(mx, mz, x1, z1, x2, z2):
    """Devuelve True si (x1,z1) está más cerca de (mx,mz) que (x2,z2)."""
    dist1 = math.hypot(mx - x1, mz - z1)
    dist2 = math.hypot(mx - x2, mz - z2)
    return dist1 <= dist2

def calcular_distancia(x1, z1, x2, z2):
    """Calcula la distancia euclidiana entre dos puntos 2D."""
    return math.hypot(x1 - x2, z1 - z2)

def calcular_punto_medio(x1, z1, x2, z2):
    """Calcula el punto medio entre dos posiciones (devuelve tupla x,0,z)."""
    return ((x1 + x2) / 2.0, 0.0, (z1 + z2) / 2.0)

def es_amigo(team_propio, team_objetivo):
    """Comprueba si el objetivo es del mismo equipo (evita fuego amigo)."""
    return int(team_propio) == int(team_objetivo)


# =============================================================
# Función para registrar todas las acciones comunes
# =============================================================

def registrar_acciones_comunes(agente, env):
    """Registra acciones internas compartidas por todos los tipos de agente."""

    @env.add_function(".es_mas_cercano",
                      (float, float, float, float, float, float))
    def _es_mas_cercano(mx, mz, x1, z1, x2, z2):
        return calcular_mas_cercano(mx, mz, x1, z1, x2, z2)

    @env.add_function(".distancia",
                      (float, float, float, float))
    def _distancia(x1, z1, x2, z2):
        """Acción interna: calcula distancia entre dos puntos."""
        return calcular_distancia(x1, z1, x2, z2)

    @env.add_function(".calcular_punto_medio",
                      (float, float, float, float))
    def _calcular_punto_medio(x1, z1, x2, z2):
        """Acción interna: calcula punto medio entre dos posiciones."""
        return calcular_punto_medio(x1, z1, x2, z2)

    @env.add_function(".es_amigo",
                      (int, int))
    def _es_amigo(team_propio, team_objetivo):
        """Acción interna: comprueba si el objetivo es aliado (fuego amigo)."""
        return es_amigo(team_propio, team_objetivo)


# =============================================================
# Clases de agentes personalizados
# =============================================================

class MiSoldado(BDISoldier):
    """Soldado mejorado con coordinación y anti-fuego amigo."""
    def add_custom_actions(self, env):
        super().add_custom_actions(env)
        registrar_acciones_comunes(self, env)


class MiMedico(BDIMedic):
    """Médico mejorado con respuesta a solicitudes y curación proactiva."""
    def add_custom_actions(self, env):
        super().add_custom_actions(env)
        registrar_acciones_comunes(self, env)


class MiFieldOp(BDIFieldOp):
    """FieldOp mejorado con servicio scout y suministro inteligente."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Registrar nuevo servicio "scout" para que otros agentes
        # puedan consultar quién ofrece inteligencia táctica
        self.services.append("scout")

    def add_custom_actions(self, env):
        super().add_custom_actions(env)
        registrar_acciones_comunes(self, env)