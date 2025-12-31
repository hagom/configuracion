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
    echo -e "${YELLOW}Instalando dependencia: $package...${NC}"
    if ! sudo apt update -y || ! sudo apt install -y "$package"; then
      echo -e "${RED}Error: No se pudo instalar $package.${NC}"
      exit 1
    fi
  fi
}

# --- Función para listar compresores (-l) ---
list_compressors() {
  echo -e "${BLUE}Compresores por ratio de eficiencia (Mayor a Menor):${NC}"
  echo -e "1. ${GREEN}7z${NC}  - Ultra (LZMA2). Máxima reducción."
  echo -e "2. ${GREEN}xz${NC}  - Excelente (LZMA). Estándar Linux."
  echo -e "3. ${GREEN}bz2${NC} - Alto (Bzip2). Ideal para texto."
  echo -e "4. ${GREEN}gz${NC}  - Medio (Gzip). Rápido y compatible."
  echo -e "5. ${GREEN}zip${NC} - Básico. Compatibilidad universal."
  exit 0
}

usage() {
  echo -e "${BLUE}Uso:${NC} $0 [-c|-d|-l] [-n nombre] [-u] <formato> <archivos...>"
  echo -e "Opciones:"
  echo -e "  ${GREEN}-c${NC} : Comprimir (Uso: 70% RAM / 100% CPU)"
  echo -e "  ${GREEN}-d${NC} : Descomprimir"
  echo -e "  ${GREEN}-l${NC} : Listar compresores por eficiencia"
  echo -e "  ${GREEN}-n${NC} : Nombre personalizado"
  echo -e "  ${GREEN}-u${NC} : Unificar archivos (Activo: $UNIFY)"
  exit 1
}

# --- Variables ---
MODE=""
UNIFY="No"
CUSTOM_NAME=""

# --- Procesar Banderas ---
while getopts "cduln:" opt; do
  case $opt in
  c) MODE="compress" ;;
  d) MODE="decompress" ;;
  u) UNIFY="Sí" ;;
  l) list_compressors ;;
  n) CUSTOM_NAME="$OPTARG" ;;
  *) usage ;;
  esac
done

shift $((OPTIND - 1))
FORMAT=$1
shift
INPUTS=("$@")

if [[ -z "$MODE" ]] || [[ -z "$FORMAT" ]] || [[ ${#INPUTS[@]} -eq 0 ]]; then usage; fi

# --- Cálculo de RAM y Tamaño Original ---
get_mem_limit() {
  local free_mem
  free_mem=$(free -m | awk '/^Mem:/{print $7}')
  echo $((free_mem * 70 / 100))
}

get_unique_name() {
  local base_name=$1 ext=$2 counter=1 final_name
  final_name="${base_name}.${ext}"
  if [[ -e "$final_name" ]]; then
    while [[ -e "${base_name}_${counter}.${ext}" ]]; do ((counter++)); done
    final_name="${base_name}_${counter}.${ext}"
  fi
  echo "$final_name"
}

# --- LÓGICA DE COMPRESIÓN ---
do_compress() {
  local ext mem_mb FINAL_FILE TOTAL_ORIG_BYTES=0 ORIG_HUMAN
  mem_mb=$(get_mem_limit)

  # 1. Calcular tamaño total de todos los inputs (Archivos o Carpetas)
  for item in "${INPUTS[@]}"; do
    if [[ -e "$item" ]]; then
      # du -sb obtiene el tamaño aparente en bytes
      TOTAL_ORIG_BYTES=$((TOTAL_ORIG_BYTES + $(du -sb "$item" | cut -f1)))
    fi
  done
  ORIG_HUMAN=$(numfmt --to=iec-i --suffix=B "$TOTAL_ORIG_BYTES")

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
  FINAL_FILE=$(get_unique_name "$CUSTOM_NAME" "$ext")

  echo -e "${BLUE}Analizando: ${YELLOW}$ORIG_HUMAN${BLUE} de datos originales...${NC}"

  if case $FORMAT in
    gz) tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE" ;;
    xz) tar -cvf - "${INPUTS[@]}" | xz -9e -T0 --memory="${mem_mb}MiB" >"$FINAL_FILE" ;;
    bz2) tar -I 'lbzip2 -9' -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    zip) zip -9 -r "$FINAL_FILE" "${INPUTS[@]}" ;;
    7z) 7z a -mx=9 -md=128m -ms=on -mmt=on "$FINAL_FILE" "${INPUTS[@]}" ;;
    esac then
    local FINAL_SIZE FINAL_BYTES PERCENTAGE
    FINAL_SIZE=$(du -sh "$FINAL_FILE" | cut -f1)
    FINAL_BYTES=$(du -sb "$FINAL_FILE" | cut -f1)
    
    if [ "$TOTAL_ORIG_BYTES" -gt 0 ]; then
        PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", (($TOTAL_ORIG_BYTES - $FINAL_BYTES) / $TOTAL_ORIG_BYTES) * 100}")
    else
        PERCENTAGE="0.00"
    fi

    echo -e "\n${GREEN}=======================================${NC}"
    echo -e "${BLUE}Archivo creado:${NC}    ${YELLOW}$FINAL_FILE${NC}"
    echo -e "${BLUE}Tamaño Original:${NC}   ${RED}$ORIG_HUMAN${NC}"
    echo -e "${BLUE}Tamaño Final:${NC}      ${GREEN}$FINAL_SIZE${NC}"
    echo -e "${BLUE}Tasa de Compresión:${NC} ${GREEN}${PERCENTAGE}%${NC}"
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
    echo -e "${BLUE}Extrayendo: $file${NC}"
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
