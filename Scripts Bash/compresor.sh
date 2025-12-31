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
  echo -e "${BLUE}Uso:${NC} $0 [-c|-d] [-n <nombre>] [-u] <formato> <archivos...>"
  echo -e "Opciones:"
  echo -e "  ${GREEN}-c${NC} : Comprimir"
  echo -e "  ${GREEN}-d${NC} : Descomprimir"
  echo -e "  ${GREEN}-n${NC} : Nombre personalizado (Opcional, por defecto usa el nombre del original)"
  echo -e "  ${GREEN}-u${NC} : Unificar todos los inputs en un solo archivo"
  echo -e "Formatos: ${YELLOW}gz, xz, bz2, zip, 7z${NC}"
  exit 1
}

# --- Variables de control ---
MODE=""
UNIFY=false
CUSTOM_NAME=""
FORMAT=""

# --- Procesar Banderas ---
while getopts "cdun:" opt; do
  case $opt in
  c) MODE="compress" ;;
  d) MODE="decompress" ;;
  u) UNIFY=true ;;
  n) CUSTOM_NAME="$OPTARG" ;;
  *) usage ;;
  esac
done

shift $((OPTIND - 1))
FORMAT=$1
shift
INPUTS=("$@")

# Validaciones de argumentos
if [[ -z "$MODE" ]] || [[ -z "$FORMAT" ]] || [[ ${#INPUTS[@]} -eq 0 ]]; then
  usage
fi

# --- Función para generar nombre único (Autoincremento) ---
get_unique_name() {
  local base_name=$1
  local ext=$2
  local final_name="${base_name}.${ext}"
  local counter=1

  if [[ -e "$final_name" ]]; then
    echo -e "${YELLOW}Advertencia: El archivo '$final_name' ya existe.${NC}"
    while [[ -e "${base_name}_${counter}.${ext}" ]]; do
      ((counter++))
    done
    final_name="${base_name}_${counter}.${ext}"
    echo -e "${BLUE}Se usará el nombre: ${GREEN}$final_name${NC}"
  fi
  echo "$final_name"
}

# --- LÓGICA DE COMPRESIÓN ---
do_compress() {
  local ext=""
  case $FORMAT in
  gz)
    ext="tar.gz"
    ensure_tool "pigz" "pigz"
    ;;
  xz)
    ext="tar.xz"
    ensure_tool "xz" "xz-utils"
    ;;
  bz2)
    ext="tar.bz2"
    ensure_tool "lbzip2" "lbzip2"
    ;;
  zip)
    ext="zip"
    ensure_tool "zip" "zip"
    ;;
  7z)
    ext="7z"
    ensure_tool "7z" "p7zip-full"
    ;;
  *)
    echo -e "${RED}Formato no válido${NC}"
    exit 1
    ;;
  esac

  # LÓGICA DE NOMBRE AUTOMÁTICO:
  # Si CUSTOM_NAME está vacío, toma el nombre del primer input eliminando barras diagonales.
  if [[ -z "$CUSTOM_NAME" ]]; then
    CUSTOM_NAME="${INPUTS[0]%/}"
  fi

  local FINAL_FILE
  FINAL_FILE=$(get_unique_name "$CUSTOM_NAME" "$ext")

  # Tamaño original
  local TOTAL_BYTES=0
  for item in "${INPUTS[@]}"; do
    [ -e "$item" ] && TOTAL_BYTES=$((TOTAL_BYTES + $(du -sb "$item" | cut -f1)))
  done
  local ORIG_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_BYTES)

  echo -e "${BLUE}Modo: Compresión Máxima (${YELLOW}$FORMAT${BLUE})${NC}"

  case $FORMAT in
  gz) tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE" ;;
  xz) tar -cvf - "${INPUTS[@]}" | xz -9e -T0 >"$FINAL_FILE" ;;
  bz2) tar -I lbzip2 -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
  zip) zip -9 -r "$FINAL_FILE" "${INPUTS[@]}" ;;
  7z) 7z a -mx=9 -ms=on "$FINAL_FILE" "${INPUTS[@]}" ;;
  esac

  if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}=======================================${NC}"
    echo -e "${BLUE}Archivo creado:${NC} ${YELLOW}$FINAL_FILE${NC}"
    echo -e "${BLUE}Tamaño Original:${NC} ${RED}$ORIG_HUMAN${NC}"
    echo -e "${BLUE}Tamaño Final:${NC}    ${GREEN}$(du -sh "$FINAL_FILE" | cut -f1)${NC}"
    echo -e "${GREEN}=======================================${NC}"
  fi
}

# --- LÓGICA DE DESCOMPRESIÓN ---
do_decompress() {
  for file in "${INPUTS[@]}"; do
    if [ ! -f "$file" ]; then
      echo -e "${RED}Error: $file no existe.${NC}"
      continue
    fi
    echo -e "${BLUE}Extrayendo $file...${NC}"
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

if [[ "$MODE" == "compress" ]]; then
  do_compress
else
  do_decompress
fi
