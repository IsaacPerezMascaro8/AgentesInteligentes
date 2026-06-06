// ============================================================
// MÉDICO ALLIED (Team 100) — Práctica 2 Agentes Inteligentes
//
// ESTRATEGIA: "MÉDICO COBARDE" (Ancla de Retaguardia)
//   - Se ancla a un 30% del camino entre base y bandera
//   - Broadcast periódico de posición a soldados
//   - NUNCA avanza a zonas de combate
//   - El soldado herido retrocede al médico, no al revés
//
// CRITERIOS CUBIERTOS:
//   1. Mensajes: broadcast posición (tell), Contract Net curación
//   2. Servicio: consulta servicio "intel"
//   3. Comportamiento: ancla retaguardia + curación de área
// ============================================================


// ===================== INICIALIZACIÓN ========================

+flag(F) : team(100)
  <-
  .print("Médico Cobarde: calculando posición de retaguardia");
  .get_medics;
  .get_backups;
  .get_fieldops;
  .get_service("intel");            // CRITERIO 2: consultar servicio intel
  ?base(B);
  .calculate_midpoint(B, F, Mid);
  +anchor_position(Mid);
  +supporting;
  .goto(Mid).

// CRITERIO 2: Reaccionar al recibir la lista de agentes intel
+intel(L) : team(100)
  <-
  .length(L, N);
  !contact_intel(L, N).

+!contact_intel(L, N) : N > 0
  <-
  .nth(0, L, IntelAgent);
  .send(IntelAgent, tell, medic_ready("online"));
  .print("Médico: notificado al scout que estoy operativo").

+!contact_intel(_, 0)
  <-
  .print("Médico: no hay agentes intel disponibles").


// ===== MÉDICO COBARDE: ANCLAJE Y BROADCASTING ====

// Al llegar al punto de anclaje, iniciar curación y broadcasting
+target_reached(T) : supporting & team(100) & not ayudando(_,_)
  <-
  -target_reached(T);
  .print("Médico Cobarde: anclado en retaguardia segura");
  .cure;
  !!broadcast_position_loop;
  !!area_heal_loop.

// Broadcast periódico de posición a todos los soldados
+!broadcast_position_loop : supporting & team(100) & my_backups(Backups)
  <-
  ?position(MyPos);
  .length(Backups, NB);
  !send_medic_pos(Backups, NB, MyPos);
  .wait(5000);
  !!broadcast_position_loop.

+!broadcast_position_loop.

+!send_medic_pos(List, N, Pos) : N > 0
  <-
  .nth(N-1, List, Agent);
  .send(Agent, tell, medic_position(Pos));
  !send_medic_pos(List, N-1, Pos).

+!send_medic_pos(_, 0, _).


// ===== CONTRACT NET (MÉDICO COBARDE: NO ME MUEVO) ====

// Propuesta: envío mi posición actual. Me quedo aquí.
+savemeproposal(Pos)[source(A)] : team(100) & not ayudando(_,_)
  <-
  ?position(MiPos);
  .send(A, tell, mybid(MiPos));
  +ayudando(A, MiPos);
  -savemeproposal(Pos)[source(A)].

// Ignorar si ya estoy ayudando
+savemeproposal(Pos)[source(A)] : team(100) & ayudando(_,_)
  <-
  -savemeproposal(Pos)[source(A)].

// Aceptación: curo desde mi posición, el herido viene a mí
+acceptproposal[source(A)] : team(100) & ayudando(A, Pos)
  <-
  .cure;
  .wait(500);
  .cure;
  -ayudando(A, Pos);
  -acceptproposal[source(A)].

// Cancelación
+cancelproposal[source(A)] : team(100) & ayudando(A, Pos)
  <-
  -ayudando(A, Pos);
  -cancelproposal[source(A)].

// Si llega alguien mientras ayudo
+target_reached(T) : team(100) & ayudando(_,_)
  <-
  -target_reached(T).


// ===== CURACIÓN DE ÁREA PERIÓDICA ====

+!area_heal_loop : supporting & team(100) & not ayudando(_,_)
  <-
  .wait(2000);
  .cure;
  .turn(0.5);
  !!area_heal_loop.

+!area_heal_loop : ayudando(_,_).


// ===== COMBATE: SOLO AUTODEFENSA CERCANA ====

// Disparar solo si el enemigo está muy cerca (autodefensa)
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position) : team(100) & Distance < 15
  <-
  .shoot(1, Position).

// Ignorar enemigos lejanos (no atraer atención)
+enemies_in_fov(_, _, _, _, _, _) : team(100).


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
  .print("MEDPACK!");
  .cure;
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
