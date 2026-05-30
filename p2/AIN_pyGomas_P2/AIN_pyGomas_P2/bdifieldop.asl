// ================================================================
// bdifieldop.asl — FieldOp Allied (team 100)
// ================================================================
// COPIA EXACTA del flujo que GANÓ + servicio scout
// El fieldop NUNCA cambia de ruta por mensajes (recarga en sitio)
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
    <- .reload;
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
// ALLIED — FieldOp (flujo original que ganó + scout)
// ================================================================

// 1. Ir a la bandera, registrar servicio scout
+flag(F): team(100)
    <- .register_service("scout");
       .goto(F).

// 2. Recargar periódicamente mientras camina (igual que original)
+heading(H): team(100)
    <-
    .wait(1000);
    .reload.

// 3. Disparar a enemigos (3 disparos, agresivo)
+enemies_in_fov(ID,Type,Angle,Dist,Health,Pos): team(100)
    <- .shoot(3,Pos).

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
// EXTRAS — NO cambian rutas
// ================================================================

// Al recibir need_ammo: recargar AQUÍ (no ir al soldado)
+need_ammo(Pos)[source(A)]: team(100)
    <- .reload.

// Inteligencia scout: redistribuir reportes de enemigos
+enemy_spotted(Pos)[source(A)]: team(100)
    <- .broadcast(tell, enemy_alert(Pos)).