// ============================================================
// SOLDADO ALLIED (Team 100) — Práctica 2 Agentes Inteligentes
// 
// CRITERIOS CUBIERTOS:
//   1. Mensajes: broadcast enemigos (tell), petición escolta (achieve),
//      petición curación (achieve)
//   2. Servicio: registra servicio "intel"
//   3. Comportamiento: anti-friendly-fire con safe_shoot
//   4. Acción Python: .calculate_threat_level
// ============================================================


// ===================== INICIALIZACIÓN ========================

+flag(F) : team(100)
  <-
  .print("Soldado Allied: inicializando misión");
  .register_service("intel");       // CRITERIO 2: registrar servicio
  .get_medics;
  .get_backups;
  .get_fieldops;
  // Crear punto de aproximación PERSONAL aleatorio alrededor de la bandera
  .create_control_points(F, 20, 1, C);
  .nth(0, C, MyApproach);
  +my_approach_point(MyApproach);
  +exploring;
  !!advance_to_flag(F).


// ========== CRITERIO 1: ALERTA DE ENEMIGOS (tell) ===========

// Al detectar enemigo CON listas de compañeros disponibles y sin alertar recientemente (Cooldown)
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position) 
  : team(100) & my_backups(Backups) & my_medics(Medics) & not alerting
  <-
  +alerting;
  // Informar a soldados
  .length(Backups, NB);
  !broadcast_alert(Backups, NB, Position);
  // Informar a médicos
  .length(Medics, NM);
  !broadcast_alert(Medics, NM, Position);
  // Disparo seguro (CRITERIO 3 + 4)
  ?position(MyPos);
  !safe_shoot(3, Position, MyPos);
  .wait(2000);
  -alerting.

// Fallback: Disparo directo sin hacer broadcast (cuando hay cooldown o faltan listas)
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position) : team(100) & not shooting
  <-
  +shooting;
  ?position(MyPos);
  !safe_shoot(3, Position, MyPos);
  .wait(1000);
  -shooting.

// Ignorar eventos adicionales silenciosamente si ya estamos disparando
+enemies_in_fov(_, _, _, _, _, _).

// Broadcast recursivo de alertas
+!broadcast_alert(List, N, Pos) : N > 0
  <-
  .nth(N-1, List, Agent);
  .send(Agent, tell, enemy_alert(Pos));
  !broadcast_alert(List, N-1, Pos).

+!broadcast_alert(_, 0, _).

// Reacción al recibir alerta de un compañero
+enemy_alert(Pos) : exploring & team(100)
  <-
  .look_at(Pos).


// ========= CRITERIO 1: CAPTURA Y ESCOLTA (achieve) ==========

+flag_taken : team(100)
  <-
  .print("¡BANDERA CAPTURADA! Regresando a la base de inmediato...");
  ?base(B);
  .goto(B);       // 1º MOVERSE: Aseguramos que el agente corra hacia la base
  +returning;
  -exploring;
  !!pedir_escolta(B). // 2º COMUNICAR: Lanzamos la petición de escolta en paralelo

// Plan paralelo y seguro para pedir escolta
+!pedir_escolta(B) : my_backups(Backups)
  <-
  .length(Backups, NB);
  !request_escort(Backups, NB, B).

// Fallback: Si la lista de compañeros falla, seguimos corriendo en silencio
+!pedir_escolta(B).

+!request_escort(List, N, Base) : N > 0
  <-
  .nth(N-1, List, Agent);
  .send(Agent, achieve, escort_to(Base));
  !request_escort(List, N-1, Base).

+!request_escort(_, 0, _).

// Responder a petición de escolta: quedarse limpiando enemigos para cubrir al portador
+!escort_to(Base) : team(100) & not returning
  <-
  .print("Cubriendo al portador: limpiando enemigos restantes");
  // NO ir a la base — el portador corre solo
  // Nosotros seguimos en exploring, patrullando y eliminando defensores
  ?flag(F);
  !!advance_to_flag(F).

// Si ya estoy volviendo, ignorar la petición
+!escort_to(_) : returning.


// ======== CRITERIO 1: PEDIR CURACIÓN (MÉDICO COBARDE) ==============

// Recibir posición del médico (broadcast periódico del Médico Cobarde)
+medic_position(Pos)[source(A)] : team(100)
  <-
  -+known_medic_pos(Pos).

// 1º VERSIÓN COBARDE: Retroceder AL MÉDICO inmediatamente + Contract Net
+health(H) : H < 50 & team(100) & known_medic_pos(MedicPos) & my_medics(M) & not pedidaayuda
  <-
  .print("Herido! Retrocediendo al Médico Cobarde");
  +pedidaayuda;
  +seeking_heal;
  -exploring;
  .goto(MedicPos);
  ?position(Pos);
  +bids([]);
  +agents([]);
  .send(M, tell, savemeproposal(Pos));
  .wait(1000);
  !!elegirmejor.

// Fallback: sin posición conocida del médico, Contract Net clásico
+health(H) : H < 50 & team(100) & my_medics(M) & not pedidaayuda
  <-
  .print("Pido ayuda médica (sin posición del médico)");
  +pedidaayuda;
  ?position(Pos);
  +bids([]);
  +agents([]);
  .send(M, tell, savemeproposal(Pos));
  .wait(1000);
  !!elegirmejor.

// 2º El soldado recibe y acumula las propuestas (Fase Propose)
+mybid(Pos)[source(A)] : pedidaayuda
  <-
  ?bids(B);
  .concat(B, [Pos], B1); 
  -+bids(B1);
  ?agents(Ag);
  .concat(Ag, [A], Ag1); 
  -+agents(Ag1);
  -mybid(Pos).

// 3º El soldado evalúa y elige al primer médico de la lista (Fase Accept/Reject)
+!elegirmejor : bids(Bi) & agents(Ag) & not (Ag == [])
  <-
  ?position(MyPos);
  .closest_position_index(MyPos, Bi, Idx);
  .nth(Idx, Bi, Pos);
  .nth(Idx, Ag, A);
  .send(A, tell, acceptproposal);
  .delete(Idx, Ag, Ag1);
  .send(Ag1, tell, cancelproposal);
  +seeking_heal;
  -exploring;
  .goto(Pos);
  -+bids([]);
  -+agents([]).

// Fallback: Si nadie ha respondido a la petición
+!elegirmejor : bids([])
  <-
  .print("Nadie me puede ayudar");
  -+bids([]);
  -+agents([]);
  -pedidaayuda.

// Reset de la creencia cuando la salud vuelva a estar bien
+health(H) : H >= 60 & pedidaayuda
  <-
  -pedidaayuda;
  -seeking_heal;
  +exploring;
  ?flag(F);
  !!advance_to_flag(F).


// ====== CRITERIO 3 + 4: DISPARO SEGURO (anti-friendly fire) =====

// CASO 1: Hay aliado cerca (<20 unidades) → modo cauteloso
// Solo disparo si el enemigo está MUY cerca (autodefensa) y a potencia mínima
+!safe_shoot(Power, EnemyPos, MyPos) : team(100)
  & friends_in_fov(_, _, _, FD, _, _) & FD < 20
  <-
  .calculate_threat_level(MyPos, EnemyPos, Threat);
  !decide_fire_careful(Threat, EnemyPos).

// CASO 2: Sin aliados cerca → disparo libre con threat level (CRITERIO 4)
+!safe_shoot(Power, EnemyPos, MyPos) : team(100)
  <-
  .calculate_threat_level(MyPos, EnemyPos, Threat);
  !decide_fire(Power, EnemyPos, Threat).

// --- Modo cauteloso (aliado cerca): Disparo de apoyo ---
// Disparamos a potencia mínima (1) para no hacer demasiado daño a un posible compañero,
// pero mantenemos la presión ofensiva sobre el enemigo.
+!decide_fire_careful(_, Pos)
  <-
  .look_at(Pos);
  .shoot(1, Pos).

// --- Modo libre (sin aliados cerca): DISPARAR A MATAR ---
// Siempre disparo a MÁXIMA potencia independientemente de la amenaza
+!decide_fire(Power, Pos, _)
  <-
  .look_at(Pos);
  .shoot(Power, Pos).


// ================== NAVEGACIÓN ===============================

+target_reached(T) : exploring & team(100)
  <-
  -target_reached(T);
  ?flag(F);
  !!advance_to_flag(F).

+target_reached(T) : escorting & team(100)
  <-
  -target_reached(T);
  -escorting;
  +exploring;
  ?flag(F);
  .goto(F).

+target_reached(T) : returning & team(100)
  <-
  -target_reached(T).

+target_reached(T) : seeking_heal & team(100)
  <-
  -target_reached(T);
  -seeking_heal;
  +exploring;
  ?flag(F);
  !!advance_to_flag(F).


// ============= AVANCE DISTRIBUIDO (cada soldado su ruta) ==============

// 1º Ir al punto de aproximación personal (dispersión natural)
+!advance_to_flag(F) : team(100) & exploring & my_approach_point(AP) & not approached
  <-
  +approached;
  .goto(AP).

// 2º Ya pasé por mi punto: ahora directo a la bandera
+!advance_to_flag(F) : team(100) & exploring
  <-
  -approached;
  .goto(F).

// Fallback: si no estoy exploring (escoltando, curándome, etc.) → no hacer nada
+!advance_to_flag(_).




// ================ TEAM AXIS (200) — Defensa ==================

+flag(F) : team(200)
  <-
  .create_control_points(F, 25, 4, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0).

+target_reached(T) : patrolling & team(200)
  <-
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
