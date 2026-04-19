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
  .print("AMMOPACK!");
  .reload;
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

// OPERADOR DE CAMPO (MUNICIÓN)
+flag(F) : team(100) 
  <- 
  .goto(F).

+ammo(A) : A < 40
  <- 
  .reload. // Recarga propia [cite: 608, 647]

+heading(H) : exploring
  <- 
  .wait(2000);
  .reload; // Soltar munición para el equipo [cite: 322]
  .turn(0.375).

+enemies_in_fov(ID,Type,Angle,Dist,Health,Pos)
  <- 
  .shoot(3,Pos).