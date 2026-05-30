// ================================================================
// bdimedic.asl — Médico Allied (team 100)
// ================================================================
// COPIA EXACTA del flujo que GANÓ + curación inteligente
// El médico NUNCA cambia de ruta por mensajes (solo cura en sitio)
// ================================================================

// ---------------- AXIS (defensores, NO TOCAR) ----------------

+flag (F): team(200)
    <- .create_control_points(F,25,3,C);
       +control_points(C);
       .length(C,L);
       +total_control_points(L);
       +patrolling;
       +patroll_point(0).

+target_reached(T): patrolling & team(200)
    <- .cure;
       ?patroll_point(P);
       -+patroll_point(P+1);
       -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T
    <- ?control_points(C);
       .nth(P,C,A);
       .goto(A).

+patroll_point(P): total_control_points(T) & P==T
    <- -patroll_point(P);
       +patroll_point(0).


// ================================================================
// ALLIED — Médico (flujo original que ganó)
// ================================================================

// 1. Ir a la bandera con el grupo
+flag(F): team(100)
    <- .goto(F).

// 2. Curar periódicamente mientras camina (igual que original)
+heading(H): team(100)
    <-
    .wait(1000);
    .cure.

// 3. Disparar a enemigos (autodefensa, 1 disparo)
+enemies_in_fov(ID,Type,Angle,Dist,Health,Pos): team(100)
    <- .shoot(1,Pos).

// 4. Bandera capturada: ir a casa
+flag_taken: team(100)
    <-
    ?base(B);
    .goto(B).

// 5. Escolta
+escort_flag[source(A)]: team(100)
    <-
    ?base(B);
    .goto(B).

// ================================================================
// EXTRAS — Curar al recibir solicitud (NO cambia ruta, cura en sitio)
// ================================================================

// Al recibir need_medic: curar AQUÍ (no ir al soldado)
+need_medic(Pos)[source(A)]: team(100)
    <- .cure.

// Al ver aliado herido cerca: curar
+friends_in_fov(ID,Type,Angle,Dist,Health,Pos): team(100) & Health < 50
    <- .cure.