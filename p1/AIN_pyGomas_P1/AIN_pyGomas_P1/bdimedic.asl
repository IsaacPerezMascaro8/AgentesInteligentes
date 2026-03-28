// =========================================================
// TEAM_AXIS (NUESTRO EQUIPO DEFENSOR - MÉDICOS)
// =========================================================

+flag(F): team(200) 
  <-
  .print("Médico en posición. Estableciendo hospital de campaña.");
  // Radio 8: Los médicos se quedan más cerca de la bandera, protegidos por los soldados
  .create_control_points(F, 15, 3, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0).

// --- LÓGICA DE CURACIÓN PROACTIVA ---
// Si veo a un aliado con menos de 60 de vida, voy a su posición a curarlo
+friends_in_fov(ID, Type, Angle, Dist, Health, Position): Health < 60 & team(200)
  <-
  .print("¡Aliado herido detectado! Acudiendo al rescate.");
  .goto(Position).
  // Cuando llegue a su posición saltará el target_reached de abajo y soltará el botiquín

// Si mi propia salud baja mucho, me curo a mí mismo soltando un botiquín
+health(H): H < 40 & team(200)
  <-
  .print("¡Me hieren! Curándome a mí mismo.");
  .cure.

// --- LÓGICA DE PATRULLA Y PREVENCIÓN ---
+target_reached(T): patrolling & team(200) 
  <-
  .print("Dejando botiquín preventivo.");
  .cure; // Crea un MedicPack (aumenta salud en 20) que dura 25 segundos en el suelo
  .turn(1.57); // Giro de 90 grados para escanear heridos
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

// --- LÓGICA DE COMBATE (AUTODEFENSA) ---
// Los médicos disparan menos fuerte, pero se defienden si ven al enemigo
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position): team(200)
  <-
  .shoot(3, Position).


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
  .cure;
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