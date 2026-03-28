// =========================================================
// TEAM_AXIS (NUESTRO EQUIPO DEFENSOR - FIELDOPS)
// =========================================================

+flag(F): team(200) 
  <-
  .print("Operador de campo en posición. Desplegando munición.");
  // Radio 10: Entre los médicos (8) y los soldados (12)
  .create_control_points(F, 25, 3, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0).

// --- LÓGICA DE SUPERVIVENCIA ---
// Si mi salud baja de 40 y veo un botiquín (1001), voy a curarme
+health(H): H < 40 & packs_in_fov(ID, 1001, Angle, Dist, Health, Pos) & team(200)
  <-
  .print("¡Me han dado! Buscando medicina.");
  .goto(Pos).

// Si mi propia munición baja de 30, me recargo a mí mismo
+ammo(A): A < 30 & team(200)
  <-
  .print("Quedan pocas balas en mi arma. Recargando.");
  .reload.

// --- LÓGICA DE PATRULLA Y SUMINISTRO ---
+target_reached(T): patrolling & team(200) 
  <-
  .print("Dejando paquete de munición.");
  .reload; // Crea un AmmoPack que dura 25 segundos en el mapa
  .turn(1.57); // Gira 90 grados para vigilar
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

// --- LÓGICA DE COMBATE ---
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): team(200)
  <-
  .stop; // Frena en seco para no meterse en el pelotón
  .shoot(3, Position); // Dispara 3 veces [cite: 855]
  .look_at(Position).

// =========================================================
// TEAM_ALLIED (EL ENEMIGO DE PRUEBAS)
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
  .reload;
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