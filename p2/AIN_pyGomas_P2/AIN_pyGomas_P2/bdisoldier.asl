// ================================================================
// bdisoldier.asl — Soldado Allied (team 100)
// ================================================================
// COPIA EXACTA del flujo que GANÓ + extras NO intrusivos
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
    <- ?patroll_point(P);
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
// ALLIED — EXACTAMENTE el flujo que ganó la primera partida
// ================================================================

// 1. Ir a la bandera
+flag(F): team(100)
    <- .goto(F).

// 2. Disparar a todos los enemigos (3 disparos, agresivo)
+enemies_in_fov(ID,Type,Angle,Dist,Health,Pos): team(100)
    <- .shoot(3,Pos).

// 3. Bandera capturada: avisar a todos y volver a casa
+flag_taken: team(100)
    <-
    .broadcast(tell, escort_flag);
    ?base(B);
    .goto(B).

// 4. Otro compañero capturó la bandera: ir a casa
+escort_flag[source(A)]: team(100)
    <-
    ?base(B);
    .goto(B).

// 5. Llegar a destino: esperar (el original usaba 1500)
+target_reached(T): team(100)
    <-
    .wait(1500).

// ================================================================
// EXTRAS — NO cambian rutas, solo informan/reaccionan en el sitio
// ================================================================

// Pedir médico UNA VEZ si salud baja (solo broadcast, no cambia ruta)
+health(H): team(100) & H < 50 & H > 0 & not pidio_medico
    <-
    +pidio_medico;
    ?position(MyPos);
    .broadcast(tell, need_medic(MyPos)).

+health(H): team(100) & H >= 60 & pidio_medico
    <- -pidio_medico.

// Pedir munición UNA VEZ si poca (solo broadcast, no cambia ruta)
+ammo(A): team(100) & A < 20 & not pidio_ammo
    <-
    +pidio_ammo;
    ?position(MyPos);
    .broadcast(tell, need_ammo(MyPos)).

+ammo(A): team(100) & A >= 40 & pidio_ammo
    <- -pidio_ammo.