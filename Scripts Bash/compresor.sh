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
  echo -e "  ${GREEN}-c${NC} : Comprimir (Máximo uso de CPU/RAM)"
  echo -e "  ${GREEN}-d${NC} : Descomprimir"
  echo -e "  ${GREEN}-n${NC} : Nombre personalizado (Opcional)"
  echo -e "  ${GREEN}-u${NC} : Unificar todos los archivos en uno solo"
  exit 1
}

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

# --- Lógica de nombre único ---
get_unique_name() {
  local base_name=$1
  local ext=$2
  local final_name="${base_name}.${ext}"
  local counter=1
  if [[ -e "$final_name" ]]; then
    while [[ -e "${base_name}_${counter}.${ext}" ]]; do ((counter++)); done
    final_name="${base_name}_${counter}.${ext}"
  fi
  echo "$final_name"
}

# --- LÓGICA DE COMPRESIÓN AGRESIVA ---
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

  if [[ -z "$CUSTOM_NAME" ]]; then CUSTOM_NAME="${INPUTS[0]%/}"; fi
  local FINAL_FILE=$(get_unique_name "$CUSTOM_NAME" "$ext")

  echo -e "${BLUE}Iniciando Compresión ULTRA (Máxima RAM/CPU)...${NC}"

  case $FORMAT in
  gz)
    # pigz -9 usa el máximo nivel. Usa todos los hilos por defecto.
    tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE"
    ;;
  xz)
    # -9e: Extreme. -T0: Todos los hilos. --memlimit: 80% de la RAM total.
    tar -cvf - "${INPUTS[@]}" | xz -9e -T0 --memory=80% >"$FINAL_FILE"
    ;;
  bz2)
    # lbzip2 es paralelo y usa el máximo con -9.
    tar -I 'lbzip2 -9' -cvf "$FINAL_FILE" "${INPUTS[@]}"
    ;;
  zip)
    # zip no es tan eficiente en memoria, pero forzamos nivel 9.
    zip -9 -r "$FINAL_FILE" "${INPUTS[@]}"
    ;;
  7z)
    # -mx9: Ultra. -md=128m: Diccionario grande (usa mucha RAM). -ms=on: Sólido.
    7z a -mx=9 -md=128m -ms=on -mmt=on "$FINAL_FILE" "${INPUTS[@]}"
    ;;
  esac

  if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}✔ Archivo creado con éxito: $FINAL_FILE${NC}"
    echo -e "${BLUE}Tamaño final: ${GREEN}$(du -sh "$FINAL_FILE" | cut -f1)${NC}"
  fi
}

# --- LÓGICA DE DESCOMPRESIÓN ---
do_decompress() {
  for file in "${INPUTS[@]}"; do
    [ ! -f "$file" ] && continue
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
