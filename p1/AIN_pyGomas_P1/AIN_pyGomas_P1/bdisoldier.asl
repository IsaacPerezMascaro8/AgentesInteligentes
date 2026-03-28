// =========================================================
// TEAM_AXIS (NUESTRO EQUIPO DEFENSOR)
// =========================================================

+flag(F): team(200)
  <-
  .print("¡Posiciones defensivas! Protegiendo la bandera.");
  // Creamos puntos de control muy cerca de la bandera (radio 12 en lugar de 25)
  .create_control_points(F, 40, 5, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0).

// --- LÓGICA DE PATRULLA INTELIGENTE ---
+target_reached(T): patrolling & team(200)
  <-
  // Al llegar a mi puesto, giro 90 grados (1.57 rad) para vigilar el entorno
  .turn(1.57); 
  .wait(1000);
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T & team(200)
  <-
  ?control_points(C);
  .nth(P, C, A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T & team(200)
  <-
  -patroll_point(P);
  +patroll_point(0).

// --- LÓGICA DE SUPERVIVENCIA ---
// Si mi salud baja de 40 y veo un paquete de vida (1001), voy a por él a curarme
+health(H): H < 40 & packs_in_fov(ID, 1001, Angle, Dist, Health, Pos) & team(200)
  <-
  .print("¡Salud crítica! Buscando botiquín.");
  .goto(Pos).

// Si mi munición baja de 20 y veo un paquete de munición (1002), voy a por él
+ammo(A): A < 20 & packs_in_fov(ID, 1002, Angle, Dist, Health, Pos) & team(200)
  <-
  .print("¡Sin balas! Recargando.");
  .goto(Pos).

// --- LÓGICA DE COMBATE ---
// Si veo a un enemigo, le disparo 3 veces y me quedo mirando hacia allí por si se mueve
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): team(200)
  <-
  .shoot(3, Position);
  .look_at(Position). 

// =========================================================
// TEAM_ALLIED (EL ENEMIGO DE PRUEBAS)
// Comportamiento básico de ir a lo loco a por la bandera
// =========================================================

+flag(F): team(100)
  <-
  .goto(F).

+flag_taken: team(100)
  <-
  .print("In ASL, TEAM_ALLIED flag_taken");
  ?base(B);
  +returning;
  .goto(B);
  -exploring.

+heading(H): exploring & team(100)
  <-
  .wait(2000);
  .turn(0.375).

+target_reached(T): team(100)
  <-
  .print("target_reached");
  +exploring;
  .turn(0.375).

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): team(100)
  <-
  .shoot(3,Position).