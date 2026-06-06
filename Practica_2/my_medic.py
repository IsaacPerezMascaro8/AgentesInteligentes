"""
Práctica 2 — Agentes Inteligentes
Clase custom MyBDIMedic con acción interna .calculate_midpoint

Estrategia "Médico Cobarde": se ancla en retaguardia y nunca avanza.
"""
from pygomas.bdimedic import BDIMedic


class MyBDIMedic(BDIMedic):
    """
    Médico personalizado que calcula un punto de anclaje en retaguardia.
    Acción interna: .calculate_midpoint(PosA, PosB, Result)
    """

    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".calculate_midpoint", (tuple, tuple))
        def _calculate_midpoint(pos_a, pos_b):
            """
            Calcula punto intermedio entre base (pos_a) y bandera (pos_b).
            Sesgado al 30% hacia la bandera (70% cerca de la base = seguro).

            Returns:
                tuple: posición intermedia (x, y, z)
            """
            weight = 0.75  # 75% hacia la bandera — punto ideal (seguro pero accesible)
            mid_x = float(pos_a[0]) + (float(pos_b[0]) - float(pos_a[0])) * weight
            mid_y = float(pos_a[1]) + (float(pos_b[1]) - float(pos_a[1])) * weight
            mid_z = float(pos_a[2]) + (float(pos_b[2]) - float(pos_a[2])) * weight
            return (mid_x, mid_y, mid_z)
