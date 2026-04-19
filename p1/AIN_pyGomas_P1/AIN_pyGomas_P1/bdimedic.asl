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
  .print("MEDPACK!");
  .cure;
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


// ESTRATEGIA: SOPORTE MÓVIL (MÉDICO)

+flag(F): team(100) 
  <- 
  .goto(F).

// Generar paquetes de salud periódicamente mientras avanza
+heading(H): team(100)
  <- 
  .wait(2500);
  .cure; 
  .turn(0.375).

// Si su salud es baja, se cura a sí mismo
+health(H): H < 50
  <- 
  .cure.

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
  .shoot(1,Position). // Disparo de cobertura mínimo