#!/bin/bash

# --- Colores ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Función para auto-instalar herramientas (Estilo SC2181 corregido) ---
ensure_tool() {
  local tool=$1
  local package=$2
  if ! command -v "$tool" &>/dev/null; then
    echo -e "${YELLOW}Herramienta '$tool' no encontrada. Instalando $package...${NC}"
    # Evaluamos el comando directamente en el if para cumplir con ShellCheck
    if ! sudo apt update -y || ! sudo apt install -y "$package"; then
      echo -e "${RED}Error crítico: No se pudo instalar $package.${NC}"
      exit 1
    fi
    echo -e "${GREEN}Instalación de $package completada.${NC}"
  fi
}

usage() {
  echo -e "${BLUE}Uso:${NC} $0 <formato> <archivo1> <archivo2> ..."
  echo -e "Formatos: ${GREEN}gz, xz, bz2, zip, 7z${NC}"
  exit 1
}

if [ $# -lt 2 ]; then usage; fi

FORMAT=$1
shift
INPUTS=("$@")

# Nombre de salida basado en el primer elemento
FIRST_ELEMENT="${INPUTS[0]%/}"
OUTPUT_NAME="$FIRST_ELEMENT"

# --- Cálculo de Tamaño Original ---
TOTAL_ORIG_BYTES=0
for item in "${INPUTS[@]}"; do
  if [ -e "$item" ]; then
    SIZE=$(du -sb "$item" | cut -f1)
    TOTAL_ORIG_BYTES=$((TOTAL_ORIG_BYTES + SIZE))
  else
    echo -e "${RED}Salteando: '$item' no existe.${NC}"
  fi
done

# Convertir a formato legible
ORIG_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_ORIG_BYTES)

echo -e "${BLUE}Comprimiendo en formato: ${YELLOW}$FORMAT${NC}"

# --- Proceso de Compresión (Evaluación directa de salida) ---
compress_success=false

case $FORMAT in
gz)
  ensure_tool "pigz" "pigz"
  if tar -cvf - "${INPUTS[@]}" | pigz -9 >"${OUTPUT_NAME}.tar.gz"; then
    FINAL_FILE="${OUTPUT_NAME}.tar.gz"
    compress_success=true
  fi
  ;;
xz)
  ensure_tool "xz" "xz-utils"
  if tar -cvf - "${INPUTS[@]}" | xz -9e -T0 >"${OUTPUT_NAME}.tar.xz"; then
    FINAL_FILE="${OUTPUT_NAME}.tar.xz"
    compress_success=true
  fi
  ;;
bz2)
  ensure_tool "lbzip2" "lbzip2"
  if tar -I lbzip2 -cvf "${OUTPUT_NAME}.tar.bz2" "${INPUTS[@]}"; then
    FINAL_FILE="${OUTPUT_NAME}.tar.bz2"
    compress_success=true
  fi
  ;;
zip)
  ensure_tool "zip" "zip"
  if zip -9 -r "${OUTPUT_NAME}.zip" "${INPUTS[@]}"; then
    FINAL_FILE="${OUTPUT_NAME}.zip"
    compress_success=true
  fi
  ;;
7z)
  ensure_tool "7z" "p7zip-full"
  if 7z a -mx=9 -ms=on "${OUTPUT_NAME}.7z" "${INPUTS[@]}"; then
    FINAL_FILE="${OUTPUT_NAME}.7z"
    compress_success=true
  fi
  ;;
*)
  echo -e "${RED}Formato no reconocido.${NC}"
  usage
  ;;
esac

# --- Reporte Final ---
if [ "$compress_success" = true ]; then
  FINAL_SIZE_HUMAN=$(du -sh "$FINAL_FILE" | cut -f1)
  echo -e "\n${GREEN}=======================================${NC}"
  echo -e "${BLUE}Archivo:${NC} ${YELLOW}$FINAL_FILE${NC}"
  echo -e "${BLUE}Original:${NC} ${RED}$ORIG_SIZE_HUMAN${NC}"
  echo -e "${BLUE}Final:${NC}    ${GREEN}$FINAL_SIZE_HUMAN${NC}"
  echo -e "${GREEN}=======================================${NC}"
else
  echo -e "${RED}Error durante el proceso de compresión.${NC}"
  exit 1
fi
