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
    echo -e "${YELLOW}Instalando dependencia faltante: $package...${NC}"
    if ! sudo apt update -y || ! sudo apt install -y "$package"; then
      echo -e "${RED}Error crítico: No se pudo instalar $package.${NC}"
      exit 1
    fi
  fi
}

usage() {
  echo -e "${BLUE}Uso:${NC} $0 [-c|-d] <formato> <archivo1> <archivo2> ..."
  echo -e "Opciones:"
  echo -e "  ${GREEN}-c${NC} : Comprimir"
  echo -e "  ${GREEN}-d${NC} : Descomprimir"
  echo -e "Formatos: ${YELLOW}gz, xz, bz2, zip, 7z${NC}"
  echo -e "\nEjemplo compresión: $0 -c 7z carpeta/ archivo.txt"
  echo -e "Ejemplo descompresión: $0 -d xz archivo.tar.xz"
  exit 1
}

# --- Variables de control ---
MODE=""
FORMAT=""

# --- Procesar Banderas ---
while getopts "cd" opt; do
  case $opt in
  c) MODE="compress" ;;
  d) MODE="decompress" ;;
  *) usage ;;
  esac
done

shift $((OPTIND - 1))

FORMAT=$1
shift
INPUTS=("$@")

if [[ -z "$MODE" ]] || [[ -z "$FORMAT" ]] || [[ ${#INPUTS[@]} -eq 0 ]]; then
  usage
fi

# --- LÓGICA DE COMPRESIÓN ---
do_compress() {
  local FIRST_ELEMENT="${INPUTS[0]%/}"
  local OUTPUT_NAME="$FIRST_ELEMENT"
  local TOTAL_ORIG_BYTES=0

  # Calcular tamaño original
  for item in "${INPUTS[@]}"; do
    if [ -e "$item" ]; then
      SIZE=$(du -sb "$item" | cut -f1)
      TOTAL_ORIG_BYTES=$((TOTAL_ORIG_BYTES + SIZE))
    fi
  done

  local ORIG_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_ORIG_BYTES)
  echo -e "${BLUE}Modo: Compresión Máxima (${YELLOW}$FORMAT${BLUE})${NC}"

  case $FORMAT in
  gz)
    ensure_tool "pigz" "pigz"
    tar -cvf - "${INPUTS[@]}" | pigz -9 >"${OUTPUT_NAME}.tar.gz" && FINAL="${OUTPUT_NAME}.tar.gz"
    ;;
  xz)
    ensure_tool "xz" "xz-utils"
    tar -cvf - "${INPUTS[@]}" | xz -9e -T0 >"${OUTPUT_NAME}.tar.xz" && FINAL="${OUTPUT_NAME}.tar.xz"
    ;;
  bz2)
    ensure_tool "lbzip2" "lbzip2"
    tar -I lbzip2 -cvf "${OUTPUT_NAME}.tar.bz2" "${INPUTS[@]}" && FINAL="${OUTPUT_NAME}.tar.bz2"
    ;;
  zip)
    ensure_tool "zip" "zip"
    zip -9 -r "${OUTPUT_NAME}.zip" "${INPUTS[@]}" && FINAL="${OUTPUT_NAME}.zip"
    ;;
  7z)
    ensure_tool "7z" "p7zip-full"
    7z a -mx=9 -ms=on "${OUTPUT_NAME}.7z" "${INPUTS[@]}" && FINAL="${OUTPUT_NAME}.7z"
    ;;
  *)
    echo -e "${RED}Formato no válido${NC}"
    exit 1
    ;;
  esac

  if [ -f "$FINAL" ]; then
    echo -e "\n${GREEN}✔ Éxito${NC}"
    echo -e "${BLUE}Original: ${RED}$ORIG_HUMAN${NC} | Comprimido: ${GREEN}$(du -sh "$FINAL" | cut -f1)${NC}"
  fi
}

# --- LÓGICA DE DESCOMPRESIÓN ---
do_decompress() {
  echo -e "${BLUE}Modo: Descompresión (${YELLOW}$FORMAT${BLUE})${NC}"
  for file in "${INPUTS[@]}"; do
    if [ ! -f "$file" ]; then
      echo -e "${RED}Archivo no encontrado: $file${NC}"
      continue
    fi

    case $FORMAT in
    gz)
      ensure_tool "pigz" "pigz"
      pigz -dc "$file" | tar -xvf -
      ;;
    xz)
      ensure_tool "xz" "xz-utils"
      tar -xJvf "$file"
      ;;
    bz2)
      ensure_tool "lbzip2" "lbzip2"
      tar -I lbzip2 -xvf "$file"
      ;;
    zip)
      ensure_tool "unzip" "unzip"
      unzip "$file"
      ;;
    7z)
      ensure_tool "7z" "p7zip-full"
      7z x "$file"
      ;;
    esac
  done
}

# --- Ejecución ---
if [ "$MODE" == "compress" ]; then
  do_compress
else
  do_decompress
fi
