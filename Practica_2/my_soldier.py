"""
Práctica 2 — Agentes Inteligentes
Clase custom MyBDISoldier con acción interna .calculate_threat_level

CRITERIO 4: Acción interna en Python (20%)
"""
import math
import agentspeak as asp
from pygomas.bdisoldier import BDISoldier


class MyBDISoldier(BDISoldier):
    """
    Soldado personalizado que añade una acción interna en Python:
    .calculate_threat_level(MyPos, EnemyPos, Result)
    
    Evalúa distancia al enemigo, salud propia y munición disponible
    para calcular un nivel de amenaza (0-100). El plan ASL usa este
    valor para decidir si disparar a potencia completa, reducida,
    o cancelar el disparo (anti-friendly-fire).
    """

    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".calculate_threat_level", (tuple, tuple))
        def _calculate_threat_level(my_pos, enemy_pos):
            """
            Acción interna: calcula nivel de amenaza (0-100).

            Factores evaluados:
              - Distancia euclidiana al enemigo (más cerca = más amenaza)
              - Salud actual del agente (menos salud = más urgente disparar)
              - Munición disponible (sin munición = no se puede actuar)

            Returns:
                int: valor 0-100 que el ASL usa para decidir el disparo
            """
            # Distancia euclidiana 2D (X, Z)
            dx = float(enemy_pos[0]) - float(my_pos[0])
            dz = float(enemy_pos[2]) - float(my_pos[2])
            distance = math.sqrt(dx * dx + dz * dz)

            # Factor distancia: más cerca = más peligro (0-50 puntos)
            if distance < 5:
                dist_score = 50
            elif distance < 15:
                dist_score = 40
            elif distance < 30:
                dist_score = 25
            elif distance < 60:
                dist_score = 15
            else:
                dist_score = 5

            # Factor salud: poca vida = más urgente eliminar amenaza (0-30 puntos)
            hp = self.health
            if hp < 25:
                hp_score = 30
            elif hp < 50:
                hp_score = 20
            elif hp < 75:
                hp_score = 10
            else:
                hp_score = 5

            # Factor munición: sin balas no tiene sentido disparar (0-20 puntos)
            ammo = self.ammo
            if ammo <= 0:
                ammo_score = -100  # Imposible disparar
            elif ammo < 10:
                ammo_score = 5
            elif ammo < 30:
                ammo_score = 10
            else:
                ammo_score = 20

            threat = max(0, min(100, dist_score + hp_score + ammo_score))
            return threat

        @actions.add_function(".closest_position_index", (tuple, tuple))
        def _closest_position_index(my_pos, positions):
            """
            Action: returns index of closest position in a list of positions.

            Args:
                my_pos (tuple): current position (x, y, z)
                positions (tuple): tuple of positions

            Returns:
                int: index of closest position, -1 if none
            """
            if not positions:
                return -1

            best_idx = -1
            best_dist = None
            my_x = float(my_pos[0])
            my_z = float(my_pos[2])

            for idx, pos in enumerate(positions):
                try:
                    dx = float(pos[0]) - my_x
                    dz = float(pos[2]) - my_z
                except (TypeError, IndexError, ValueError):
                    continue
                dist = (dx * dx + dz * dz) ** 0.5
                if best_dist is None or dist < best_dist:
                    best_dist = dist
                    best_idx = idx

            if best_idx < 0 and positions:
                return 0
            return best_idx
