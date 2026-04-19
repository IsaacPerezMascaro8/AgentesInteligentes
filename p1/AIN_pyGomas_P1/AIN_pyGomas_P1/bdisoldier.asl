//TEAM_AXIS

+flag (F): team(200)
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points").


+target_reached(T): patrolling & team(200)
  <-
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T
  <-
  -patroll_point(P);
  +patroll_point(0).

// ESTRATEGIA ATACANTE MEJORADA - SOLDADO
+flag(F) : team(100) 
  <- 
  +exploring;
  .goto(F). // Ir directo a la bandera [cite: 57, 590]

// Plan crucial: Si el agente coge la bandera, se activa 'flag_taken' [cite: 58, 888]
+flag_taken : team(100)
  <- 
  .print("¡BANDERA CAPTURADA!");
  ?base(B); // Consultar posición de la base [cite: 65, 621]
  +returning;
  -exploring;
  .goto(B). // Ir a la base inmediatamente [cite: 67, 596]

// Si el agente llega a la posición de la bandera pero no la ha "activado" todavía, 
// forzamos un pequeño movimiento extra para asegurar que la pise.
+target_reached(F) : exploring & team(100)
  <-
  .print("Cerca de la bandera, intentando posicionamiento exacto...");
  .goto(F). 

+enemies_in_fov(ID,Type,Angle,Dist,Health,Pos) : team(100)
  <- 
  .shoot(3,Pos). // Defensa estándar [cite: 130, 599]