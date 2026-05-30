#!/bin/bash

# Función de limpieza reforzada
cleanup() {
    echo -e "\n[!] Cerrando la partida y limpiando procesos..."
    killall -9 pyjabber 2>/dev/null
    killall -9 python 2>/dev/null
    killall -9 pygomas 2>/dev/null
    rm -f pyjabber.db
    echo "[✓] Todo limpio. ¡Listo para la siguiente prueba!"
    exit 0
}

trap cleanup SIGINT

echo "[1/5] Limpiando ejecuciones anteriores..."
killall -9 pyjabber 2>/dev/null
killall -9 python 2>/dev/null
killall -9 pygomas 2>/dev/null
rm -f pyjabber.db

source ~/miniconda3/etc/profile.d/conda.sh

echo "[2/5] Iniciando PyJabber..."
conda activate pyjabber
pyjabber &
sleep 4 

echo "[3/5] Iniciando Manager..."
conda activate pygomas
pygomas manager -j m_RodrigoIsaac@localhost -sj s_RodrigoIsaac@localhost -np 20 &
sleep 2

echo "[4/5] Abriendo el Render (Mapa)..."
conda activate pygomas
pygomas render &
sleep 2

echo "[5/5] ¡Desplegando Agentes!"
conda activate pygomas
# LA LÍNEA MÁGICA CON RUTA ABSOLUTA: $PWD inyecta tu ruta exacta actual
export PYTHONPATH="$PWD:$PYTHONPATH"
pygomas run -g pygomas_local.json

cleanup