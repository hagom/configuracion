#!/bin/bash

# --- Colores ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Función para auto-instalar herramientas ---
ensure_tool() {
  local tool=$1
  local package=$2

  if ! command -v "$tool" &>/dev/null; then
    echo -e "${YELLOW}Herramienta '$tool' no encontrada. Intentando instalar $package...${NC}"

    # Intentar actualizar e instalar
    sudo apt update -y && sudo apt install -y "$package"

    if [ $? -ne 0 ]; then
      echo -e "${RED}Error crítico: No se pudo instalar $package. Abortando.${NC}"
      exit 1
    fi
    echo -e "${GREEN}Instalación de $package completada.${NC}"
  fi
}

usage() {
  echo -e "${BLUE}Uso:${NC} $0 <archivo_o_carpeta> <formato>"
  echo -e "Formatos: ${GREEN}gz, xz, bz2, zip, 7z${NC}"
  exit 1
}

if [ $# -lt 2 ]; then usage; fi

SOURCE=$1
FORMAT=$2
DEST="${SOURCE%/}"

if [ ! -e "$SOURCE" ]; then
  echo -e "${RED}Error: '$SOURCE' no existe.${NC}"
  exit 1
fi

# --- Selección de formato y auto-instalación ---
case $FORMAT in
gz)
  ensure_tool "pigz" "pigz"
  echo -e "${BLUE}Comprimiendo en .tar.gz con pigz...${NC}"
  tar -cvf - "$SOURCE" | pigz -9 >"${DEST}.tar.gz"
  ;;
xz)
  ensure_tool "xz" "xz-utils"
  echo -e "${BLUE}Comprimiendo en .tar.xz (Máxima/Multi-hilo)...${NC}"
  tar -cvf - "$SOURCE" | xz -9e -T0 >"${DEST}.tar.xz"
  ;;
bz2)
  ensure_tool "lbzip2" "lbzip2"
  echo -e "${BLUE}Comprimiendo en .tar.bz2 con lbzip2...${NC}"
  tar -I lbzip2 -cvf "${DEST}.tar.bz2" "$SOURCE"
  ;;
zip)
  ensure_tool "zip" "zip"
  echo -e "${BLUE}Comprimiendo en .zip (Nivel 9)...${NC}"
  zip -9 -r "${DEST}.zip" "$SOURCE"
  ;;
7z)
  ensure_tool "7z" "p7zip-full"
  echo -e "${BLUE}Comprimiendo en .7z (Ultra)...${NC}"
  7z a -mx=9 -ms=on "${DEST}.7z" "$SOURCE"
  ;;
*)
  echo -e "${RED}Formato no válido.${NC}"
  usage
  ;;
esac

# --- Resultado final ---
if [ $? -eq 0 ]; then
  ORIG_SIZE=$(du -sh "$SOURCE" | cut -f1)
  FINAL_SIZE=$(du -sh "${DEST}.${FORMAT}" | cut -f1)
  echo -e "${GREEN}¡Éxito!${NC}"
  echo -e "${BLUE}Tamaño original: ${YELLOW}$ORIG_SIZE${NC}"
  echo -e "${BLUE}Tamaño comprimido: ${YELLOW}$FINAL_SIZE${NC}"
else
  echo -e "${RED}Error durante el proceso.${NC}"
fi
