#!/bin/bash

# --- Colores ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Función para auto-instalar herramientas (SC2181 Corregido) ---
ensure_tool() {
  local tool=$1
  local package=$2
  if ! command -v "$tool" &>/dev/null; then
    echo -e "${YELLOW}Instalando dependencia: $package...${NC}"
    # Se evalúa el comando directamente en el if
    if ! sudo apt update -y || ! sudo apt install -y "$package"; then
      echo -e "${RED}Error: No se pudo instalar $package.${NC}"
      exit 1
    fi
  fi
}

# --- Función para listar compresores ordenados (-l) ---
list_compressors() {
  echo -e "${BLUE}Compresores por ratio de eficiencia (Mayor a Menor):${NC}"
  echo -e "1. ${GREEN}7z${NC}  - Ultra (LZMA2). Ideal para backups masivos."
  echo -e "2. ${GREEN}xz${NC}  - Excelente (LZMA). Estándar en kernels Linux."
  echo -e "3. ${GREEN}bz2${NC} - Alto (Bzip2). Muy eficiente en archivos de texto."
  echo -e "4. ${GREEN}gz${NC}  - Medio (Gzip). El mejor balance velocidad/tamaño."
  echo -e "5. ${GREEN}zip${NC} - Básico. Compatibilidad universal."
  exit 0
}

# --- Mensaje de Uso (Corregido con -l) ---
usage() {
  echo -e "${BLUE}Uso:${NC} $0 [-c|-d|-l] [-n nombre] [-u] <formato> <archivos...>"
  echo -e "Opciones:"
  echo -e "  ${GREEN}-c${NC} : Comprimir (Máxima potencia)"
  echo -e "  ${GREEN}-d${NC} : Descomprimir"
  echo -e "  ${GREEN}-l${NC} : Listar compresores por eficiencia"
  echo -e "  ${GREEN}-n${NC} : Nombre personalizado (Opcional)"
  echo -e "  ${GREEN}-u${NC} : Unificar archivos en un solo contenedor"
  exit 1
}

# --- Variables (SC2034 Corregido: se usan en el reporte final) ---
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

# --- Cálculo de Memoria Dinámica (70% de la disponible) ---
get_mem_limit() {
  local free_mem
  # SC2155 Corregido: declaración y asignación separadas
  free_mem=$(free -m | awk '/^Mem:/{print $7}')
  echo $((free_mem * 70 / 100))
}

# --- Generar nombre único ---
get_unique_name() {
  local base_name=$1
  local ext=$2
  local final_name
  local counter=1

  final_name="${base_name}.${ext}"
  if [[ -e "$final_name" ]]; then
    echo -e "${YELLOW}Aviso: '$final_name' ya existe.${NC}"
    while [[ -e "${base_name}_${counter}.${ext}" ]]; do ((counter++)); done
    final_name="${base_name}_${counter}.${ext}"
    echo -e "${BLUE}Nuevo nombre: ${GREEN}$final_name${NC}"
  fi
  echo "$final_name"
}

# --- LÓGICA DE COMPRESIÓN (SC2181 y SC2155 Corregidos) ---
do_compress() {
  local ext mem_mb FINAL_FILE
  mem_mb=$(get_mem_limit)

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

  echo -e "${BLUE}Iniciando: RAM=${mem_mb}MB | Unificar=${UNIFY} | CPU=MAX${NC}"

  # Evaluación directa del comando (SC2181)
  if case $FORMAT in
    gz) tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE" ;;
    xz) tar -cvf - "${INPUTS[@]}" | xz -9e -T0 --memory="${mem_mb}MiB" >"$FINAL_FILE" ;;
    bz2) tar -I 'lbzip2 -9' -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    zip) zip -9 -r "$FINAL_FILE" "${INPUTS[@]}" ;;
    7z) 7z a -mx=9 -md=128m -ms=on -mmt=on "$FINAL_FILE" "${INPUTS[@]}" ;;
    esac then
    echo -e "\n${GREEN}✔ Éxito: $FINAL_FILE${NC}"
    echo -e "${BLUE}Tamaño final: ${GREEN}$(du -sh "$FINAL_FILE" | cut -f1)${NC}"
  else
    echo -e "${RED}Error: Falló la compresión.${NC}"
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

# Ejecución
if [[ "$MODE" == "compress" ]]; then
  do_compress
else
  do_decompress
fi
