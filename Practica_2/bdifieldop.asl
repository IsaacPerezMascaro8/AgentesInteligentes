// ============================================================
// OPERADOR DE CAMPO ALLIED (Team 100) — Práctica 2
//
// CRITERIOS CUBIERTOS:
//   1. Mensajes: recibe alertas de enemigos (tell),
//      notifica recarga disponible a soldados (tell)
//   2. Servicio: consulta servicio "intel" de los soldados
//   3. Comportamiento: recarga inteligente, autorecarga,
//      recarga periódica de área
// ============================================================


// ===================== INICIALIZACIÓN ========================

+flag(F) : team(100)
  <-
  .print("FieldOp Allied: inicializando suministro");
  .get_medics;
  .get_backups;
  .get_fieldops;
  .get_service("intel");            // CRITERIO 2: consultar servicio intel
  .print("FieldOp: Calculando punto de anclaje cobarde...");
  ?base(B);
  .calculate_midpoint(B, F, MidPoint);
  +supplying;
  .goto(MidPoint).

// CRITERIO 2: Reaccionar al recibir la lista de agentes intel
+intel(L) : team(100)
  <-
  .length(L, N);
  !notify_intel_ammo(L, N).

// Notificar a los agentes intel que el suministro está activo
+!notify_intel_ammo(L, N) : N > 0
  <-
  .nth(0, L, IntelAgent);
  ?position(MyPos);
  .send(IntelAgent, tell, fieldop_ready(MyPos));
  .print("FieldOp: notificado al scout que suministro activo").

+!notify_intel_ammo(_, 0)
  <-
  .print("FieldOp: no hay agentes intel disponibles").


// ===== CRITERIO 1: RECIBIR ALERTAS DE ENEMIGOS (tell) ========

+enemy_alert(Pos) : team(100)
  <-
  .look_at(Pos).

// ===== CRITERIO 3: COMPORTAMIENTO MEJORADO DE SUMINISTRO =======


// Al llegar a la bandera, soltar paquete e iniciar bucle de suministro
+target_reached(T) : supplying & team(100)
  <-
  -target_reached(T);
  .print("Llegué a retaguardia: ¡Iniciando suministro de área!");
  .reload;
  !!supply_loop.

// Bucle limpio de munición - Versión Segura (Solo avisa si la lista existe)
+!supply_loop : supplying & team(100) & my_backups(Backups)
  <-
  .wait(3000);
  .reload;
  .length(Backups, NB);
  ?position(MyPos);
  !notify_ammo(Backups, NB, MyPos);
  .turn(0.5);
  !!supply_loop.

// Fallback: Si la creencia my_backups falla o desaparece, recarga en silencio
+!supply_loop : supplying & team(100)
  <-
  .wait(3000);
  .reload;
  .turn(0.5);
  !!supply_loop.

// Broadcast recursivo de posición con munición (mantenemos tu lógica que estaba perfecta)
+!notify_ammo(List, N, Pos) : N > 0
  <-
  .nth(N-1, List, Agent);
  .send(Agent, tell, ammo_available(Pos));
  !notify_ammo(List, N-1, Pos).

+!notify_ammo(_, 0, _).

// Combate: disparo defensivo
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position) : team(100)
  <-
  .look_at(Position);
  .shoot(3, Position).


// ================ TEAM AXIS (200) — Defensa ==================

+flag(F) : team(200)
  <-
  .create_control_points(F, 25, 3, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0).

+target_reached(T) : patrolling & team(200)
  <-
  .reload;
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P) : total_control_points(T) & P<T & team(200)
  <-
  ?control_points(C);
  .nth(P, C, A);
  .goto(A).

+patroll_point(P) : total_control_points(T) & P==T & team(200)
  <-
  -patroll_point(P);
  +patroll_point(0).

+enemies_in_fov(ID, Type, Angle, Distance, Health, Position) : team(200) & not shooting
  <-
  +shooting;
  .shoot(3, Position);
  .wait(1000);
  -shooting.
