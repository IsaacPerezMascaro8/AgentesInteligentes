import pygomas.bdifieldop

class MyBDIFieldOp(pygomas.bdifieldop.BDIFieldOp):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)
        
        @actions.add_function(".calculate_midpoint", (tuple, tuple))
        def _calculate_midpoint(pos_a, pos_b):
            """
            Calcula un punto intermedio entre A y B.
            
            Args:
                pos_a (tuple): coordenada de la base (x, y, z)
                pos_b (tuple): coordenada de la bandera (x, y, z)
            
            Returns:
                tuple: posición intermedia (x, y, z)
            """
            weight = 0.75  # 75% hacia la bandera — mismo punto que el médico
            mid_x = float(pos_a[0]) + (float(pos_b[0]) - float(pos_a[0])) * weight
            mid_y = float(pos_a[1]) + (float(pos_b[1]) - float(pos_a[1])) * weight
            mid_z = float(pos_a[2]) + (float(pos_b[2]) - float(pos_a[2])) * weight
            
            return (mid_x, mid_y, mid_z)
