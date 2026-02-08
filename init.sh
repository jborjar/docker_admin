#!/bin/bash
# =============================================================
# Script de Inicializacion - Docker Admin Stack
# =============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Docker Admin Stack - Inicializacion  ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# -------------------------------------------------------------
# Verificar archivo .env
# -------------------------------------------------------------
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}[!] Archivo .env no encontrado${NC}"
    if [ -f ".env.example" ]; then
        echo -e "${GREEN}[+] Copiando .env.example a .env${NC}"
        cp .env.example .env
        echo -e "${YELLOW}[!] Revisar y ajustar configuracion en .env${NC}"
    else
        echo -e "${RED}[X] No se encontro .env.example${NC}"
        exit 1
    fi
fi

# Cargar variables
source .env

# -------------------------------------------------------------
# Verificar red Docker
# -------------------------------------------------------------
echo -e "${GREEN}[*] Verificando red Docker...${NC}"
NETWORK_NAME="${NETWORK_NAME:-vpn-proxy}"

if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}[!] Red '$NETWORK_NAME' no existe, creandola...${NC}"
    docker network create "$NETWORK_NAME"
    echo -e "${GREEN}[+] Red '$NETWORK_NAME' creada${NC}"
else
    echo -e "${GREEN}[+] Red '$NETWORK_NAME' ya existe${NC}"
fi

# -------------------------------------------------------------
# Crear directorios de datos
# -------------------------------------------------------------
echo -e "${GREEN}[*] Verificando directorios de datos...${NC}"
DATA_PATH="${DATA_PATH:-./stack_data}"

mkdir -p "$DATA_PATH/dockge/data"
mkdir -p "$DATA_PATH/portainer/data"
mkdir -p "$DATA_PATH/dockmon/data"

echo -e "${GREEN}[+] Directorios creados/verificados${NC}"

# -------------------------------------------------------------
# Verificar permisos del socket Docker
# -------------------------------------------------------------
echo -e "${GREEN}[*] Verificando socket Docker...${NC}"
if [ -S /var/run/docker.sock ]; then
    echo -e "${GREEN}[+] Socket Docker disponible${NC}"
else
    echo -e "${RED}[X] Socket Docker no encontrado${NC}"
    exit 1
fi

# -------------------------------------------------------------
# Iniciar servicios
# -------------------------------------------------------------
echo ""
echo -e "${GREEN}[*] Iniciando servicios...${NC}"
docker compose up -d

# -------------------------------------------------------------
# Mostrar estado
# -------------------------------------------------------------
echo ""
echo -e "${GREEN}[*] Estado de los servicios:${NC}"
docker compose ps

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Inicializacion Completada            ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "Acceso a servicios:"
echo -e "  - Dockge:    http://localhost:${DOCKGE_PORT:-8080}"
echo -e "  - Portainer: http://localhost:9000 (via proxy)"
echo -e "  - Dozzle:    http://localhost:8080 (via proxy)"
echo -e "  - Dockmon:   https://localhost:${DOCKMON_PORT:-8443}"
echo ""
