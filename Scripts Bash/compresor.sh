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
    # Evaluación directa de comandos (Corrige SC2181)
    if ! sudo apt update -y || ! sudo apt install -y "$package"; then
      echo -e "${RED}Error crítico: No se pudo instalar $package.${NC}"
      exit 1
    fi
  fi
}

usage() {
  echo -e "${BLUE}Uso:${NC} $0 [-c|-d] [-n <nombre>] [-u] <formato> <archivos...>"
  echo -e "Opciones: ${GREEN}-c${NC} Comprimir | ${GREEN}-d${NC} Descomprimir | ${GREEN}-u${NC} Unificar"
  exit 1
}

# --- Variables ---
MODE=""
UNIFY=false
CUSTOM_NAME=""

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

if [[ -z "$MODE" ]] || [[ -z "$FORMAT" ]] || [[ ${#INPUTS[@]} -eq 0 ]]; then usage; fi

# --- Función para nombre único ---
get_unique_name() {
  local base_name=$1
  local ext=$2
  local final_name
  local counter=1

  final_name="${base_name}.${ext}"

  if [[ -e "$final_name" ]]; then
    echo -e "${YELLOW}Aviso: '$final_name' ya existe, buscando nombre libre...${NC}"
    while [[ -e "${base_name}_${counter}.${ext}" ]]; do
      ((counter++))
    done
    final_name="${base_name}_${counter}.${ext}"
  fi
  echo "$final_name"
}

# --- LÓGICA DE COMPRESIÓN ---
do_compress() {
  local ext
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

  [[ -z "$CUSTOM_NAME" ]] && CUSTOM_NAME="${INPUTS[0]%/}"

  # Separación de declaración y asignación (Corrige SC2155)
  local FINAL_FILE
  FINAL_FILE=$(get_unique_name "$CUSTOM_NAME" "$ext")

  echo -e "${BLUE}Comprimiendo (50% RAM | Unificar: $UNIFY)...${NC}"

  # Evaluación directa del resultado del case/comando (Corrige SC2181)
  if case $FORMAT in
    gz) tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE" ;;
    xz) tar -cvf - "${INPUTS[@]}" | xz -9e -T0 --memory=50% >"$FINAL_FILE" ;;
    bz2) tar -I 'lbzip2 -9' -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    zip) zip -9 -r "$FINAL_FILE" "${INPUTS[@]}" ;;
    7z) 7z a -mx=9 -md=64m -ms=on -mmt=on "$FINAL_FILE" "${INPUTS[@]}" ;;
    esac then
    echo -e "\n${GREEN}=======================================${NC}"
    echo -e "${BLUE}Archivo:${NC} ${YELLOW}$FINAL_FILE${NC}"
    echo -e "${BLUE}Tamaño:${NC}  ${GREEN}$(du -sh "$FINAL_FILE" | cut -f1)${NC}"
    echo -e "${GREEN}=======================================${NC}"
  else
    echo -e "${RED}Error: La compresión falló.${NC}"
    exit 1
  fi
}

# --- LÓGICA DE DESCOMPRESIÓN ---
do_decompress() {
  for file in "${INPUTS[@]}"; do
    [[ ! -f "$file" ]] && continue
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

if [[ "$MODE" == "compress" ]]; then do_compress; else do_decompress; fi
