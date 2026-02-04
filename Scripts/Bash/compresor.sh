#!/bin/bash

# ==============================================================================
# SCRIPT DE COMPRESIÓN/DESCOMPRESIÓN INTELIGENTE
# ==============================================================================
# Autor: Gemini (Asistente AI)
# Descripción:
#   Herramienta unificada para gestionar archivos comprimidos en Linux.
#   - Gestiona dependencias automáticamente.
#   - Optimiza el uso de RAM y CPU (Multihilo en pigz/xz/7z).
#   - Descompresión inteligente: detecta extensiones automáticamente.
#   - Modo seguro: Opción de borrar originales solo tras éxito.
#
# Formatos soportados: 7z, xz, gz (tar.gz), zip, bz2 (tar.bz2), bz3 (tar.bz3)
# ==============================================================================

# --- Colores ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Función para auto-instalar herramientas ---
ensure_tool() {
  local tool=$1
  local package=$2
  if ! command -v "$tool" &>/dev/null; then
    echo -e "${YELLOW}[Sistema] Herramienta '$tool' no encontrada.${NC}"
    echo -e "${YELLOW}[Sistema] Instalando paquete: $package...${NC}"
    if ! sudo apt update -y || ! sudo apt install -y "$package"; then
      echo -e "${RED}[Error] No se pudo instalar $package. Verifica tu conexión o permisos.${NC}"
      exit 1
    fi
  fi
}

# --- Función para listar compresores (-l) ---
list_compressors() {
  echo -e "${BLUE}=== Tabla de Eficiencia de Compresores ===${NC}"
  echo -e "1. ${GREEN}7z${NC}  : ${YELLOW}Ultra${NC} (LZMA2). Máxima reducción, mayor uso de CPU/RAM."
  echo -e "2. ${GREEN}xz${NC}  : ${YELLOW}Excelente${NC} (LZMA). Estándar moderno en Linux."
  echo -e "3. ${GREEN}bz3${NC} : ${YELLOW}Muy Alto${NC} (Bzip3). Muy eficiente para texto y código."
  echo -e "4. ${GREEN}bz2${NC} : ${YELLOW}Alto${NC} (Bzip2). Clásico, buena relación peso/tiempo."
  echo -e "5. ${GREEN}gz${NC}  : ${YELLOW}Medio${NC} (Gzip). El más rápido y compatible."
  echo -e "6. ${GREEN}zip${NC} : ${YELLOW}Básico${NC}. Compatibilidad universal (Windows/Mac/Linux)."
  exit 0
}

# --- Ayuda y Documentación del Script ---
usage() {
  echo -e "${BLUE}======================================================${NC}"
  echo -e "${GREEN}      COMPRESOR / DESCOMPRESOR UNIVERSAL (BASH)      ${NC}"
  echo -e "${BLUE}======================================================${NC}"
  echo -e ""
  echo -e "${YELLOW}MODO COMPRESIÓN:${NC}"
  echo -e "  $0 -c <formato> [opciones] <archivos/carpetas...>"
  echo -e "  ${BLUE}Ejemplo:${NC} $0 -c 7z -n backup_fotos ./mis_fotos"
  echo -e ""
  echo -e "${YELLOW}MODO DESCOMPRESIÓN:${NC}"
  echo -e "  $0 -d [opciones] <archivos...>"
  echo -e "  ${BLUE}Ejemplo:${NC} $0 -d -r archivo1.zip archivo2.tar.gz"
  echo -e ""
  echo -e "${YELLOW}OPCIONES DISPONIBLES:${NC}"
  echo -e "  ${GREEN}-c${NC}       : Comprimir. (Formatos: 7z, xz, gz, zip, bz2, bz3)"
  echo -e "  ${GREEN}-d${NC}       : Descomprimir. (Detecta formato automáticamente)"
  echo -e "  ${GREEN}-r${NC}       : ${RED}Borrar original${NC} al finalizar (Solo si no hubo errores)."
  echo -e "  ${GREEN}-n nombre${NC}: Asignar nombre personalizado al archivo de salida."
  echo -e "  ${GREEN}-l${NC}       : Ver tabla comparativa de compresores."
  echo -e "  ${GREEN}-u${NC}       : Unificar/Forzar modo (Informativo en esta versión)."
  echo -e ""
  exit 1
}

# --- Variables Globales ---
MODE=""
UNIFY="No"
CUSTOM_NAME=""
DELETE_ORIG="No"

# --- Procesamiento de Argumentos (Getopts) ---
while getopts "cdulrn:" opt; do
  case $opt in
  c) MODE="compress" ;;
  d) MODE="decompress" ;;
  u) UNIFY="Sí" ;;
  r) DELETE_ORIG="Sí" ;;
  l) list_compressors ;;
  n) CUSTOM_NAME="$OPTARG" ;;
  *) usage ;;
  esac
done

shift $((OPTIND - 1))

# --- Validación de Argumentos ---
if [[ "$MODE" == "decompress" ]]; then
  # En modo descompresión, ignoramos el formato si el usuario lo escribió por costumbre
  case "$1" in
  gz | xz | bz2 | bz3 | zip | 7z) shift ;;
  esac
  FORMAT="auto"
  INPUTS=("$@")
else
  # En modo compresión, el primer argumento DEBE ser el formato
  FORMAT=$1
  shift
  INPUTS=("$@")
fi

# Verificar si faltan datos mínimos
if [[ -z "$MODE" ]] || [[ -z "$FORMAT" ]] || [[ ${#INPUTS[@]} -eq 0 ]]; then
  usage
fi

# --- Utilidades Internas ---

# Calcula el 70% de la RAM libre para pasárselo a xz/7z
get_mem_limit() {
  local free_mem
  free_mem=$(free -m | awk '/^Mem:/{print $7}')
  echo $((free_mem * 70 / 100))
}

# Genera nombres únicos (ej: archivo_1.zip) si el destino ya existe
get_unique_name() {
  local base_name=$1 ext=$2 counter=1 final_name
  final_name="${base_name}.${ext}"
  if [[ -e "$final_name" ]]; then
    while [[ -e "${base_name}_${counter}.${ext}" ]]; do ((counter++)); done
    final_name="${base_name}_${counter}.${ext}"
  fi
  echo "$final_name"
}

# ==============================================================================
# LÓGICA DE COMPRESIÓN
# ==============================================================================
do_compress() {
  local ext mem_mb FINAL_FILE TOTAL_ORIG_BYTES=0 ORIG_HUMAN
  mem_mb=$(get_mem_limit)

  # Calcular tamaño total de la entrada
  for item in "${INPUTS[@]}"; do
    if [[ -e "$item" ]]; then
      TOTAL_ORIG_BYTES=$((TOTAL_ORIG_BYTES + $(du -sb "$item" | cut -f1)))
    else
      echo -e "${RED}[Error] Archivo/Carpeta no encontrado: $item${NC}"
      exit 1
    fi
  done
  ORIG_HUMAN=$(numfmt --to=iec-i --suffix=B "$TOTAL_ORIG_BYTES")

  # Selección de herramienta y extensión
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
  bz3)
    ext="tar.bz3"
    ensure_tool "bzip3" "bzip3"
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
    echo -e "${RED}[Error] Formato '$FORMAT' no válido.${NC}"
    usage
    ;;
  esac

  # Definir nombre de salida
  [[ -z "$CUSTOM_NAME" ]] && CUSTOM_NAME="${INPUTS[0]%/}"
  FINAL_FILE=$(get_unique_name "$CUSTOM_NAME" "$ext")

  echo -e "${BLUE}[Info] Comprimiendo ${YELLOW}$ORIG_HUMAN${BLUE} de datos en formato ${GREEN}$FORMAT${BLUE}...${NC}"

  # Ejecución de compresión
  local CMD_SUCCESS=false
  if case $FORMAT in
    gz) tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE" ;;
    xz) tar -cvf - "${INPUTS[@]}" | xz -9e -T0 --memory="${mem_mb}MiB" >"$FINAL_FILE" ;;
    bz2) tar -I 'lbzip2 -9' -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    bz3) tar -I 'bzip3' -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    zip) zip -9 -r "$FINAL_FILE" "${INPUTS[@]}" ;;
    7z) 7z a -mx=9 -md=128m -ms=on -mmt=on "$FINAL_FILE" "${INPUTS[@]}" ;;
    esac then
    CMD_SUCCESS=true
  fi

  if [ "$CMD_SUCCESS" = true ]; then
    local FINAL_SIZE FINAL_BYTES PERCENTAGE
    FINAL_SIZE=$(du -sh "$FINAL_FILE" | cut -f1)
    FINAL_BYTES=$(du -sb "$FINAL_FILE" | cut -f1)

    if [ "$TOTAL_ORIG_BYTES" -gt 0 ]; then
      PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", (($TOTAL_ORIG_BYTES - $FINAL_BYTES) / $TOTAL_ORIG_BYTES) * 100}")
    else
      PERCENTAGE="0.00"
    fi

    echo -e "\n${GREEN}=== Reporte de Compresión ===${NC}"
    echo -e "${BLUE}Archivo Salida:${NC}    ${YELLOW}$FINAL_FILE${NC}"
    echo -e "${BLUE}Tamaño Original:${NC}   ${RED}$ORIG_HUMAN${NC}"
    echo -e "${BLUE}Tamaño Final:${NC}      ${GREEN}$FINAL_SIZE${NC}"
    echo -e "${BLUE}Ahorro de espacio:${NC} ${GREEN}${PERCENTAGE}%${NC}"
    echo -e "${GREEN}===========================${NC}"
  else
    echo -e "${RED}[Fatal] La compresión falló. Verifica espacio en disco o permisos.${NC}"
    rm -f "$FINAL_FILE" 2>/dev/null
    exit 1
  fi
}

# ==============================================================================
# LÓGICA DE DESCOMPRESIÓN
# ==============================================================================
do_decompress() {
  for file in "${INPUTS[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo -e "${RED}[Saltando] '$file' no es un archivo válido.${NC}"
      continue
    fi

    echo -e "${BLUE}[Procesando] Archivo: ${YELLOW}$file${NC}"
    local SUCCESS=0

    # Detección de formato insensible a mayúsculas
    case "${file,,}" in
    *.tar.gz | *.tgz)
      ensure_tool "pigz" "pigz"
      pigz -dc "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.tar.xz | *.txz)
      ensure_tool "xz" "xz-utils"
      tar -xJvf "$file"
      SUCCESS=$?
      ;;
    *.tar.bz2 | *.tbz2)
      ensure_tool "lbzip2" "lbzip2"
      tar -I lbzip2 -xvf "$file"
      SUCCESS=$?
      ;;
    *.tar.bz3)
      ensure_tool "bzip3" "bzip3"
      tar -I bzip3 -xvf "$file"
      SUCCESS=$?
      ;;
    *.zip)
      ensure_tool "unzip" "unzip"
      unzip "$file"
      SUCCESS=$?
      ;;
    *.7z)
      ensure_tool "7z" "p7zip-full"
      7z x "$file"
      SUCCESS=$?
      ;;
    *)
      # Intento genérico con tar
      if [[ "$file" == *.tar ]]; then
        tar -xvf "$file"
        SUCCESS=$?
      else
        echo -e "${RED}[Error] Formato desconocido o no soportado para: $file${NC}"
        SUCCESS=1
      fi
      ;;
    esac

    # Gestión de borrado (-r)
    if [ $SUCCESS -eq 0 ]; then
      echo -e "${GREEN}[Éxito] Archivo descomprimido correctamente.${NC}"
      if [[ "$DELETE_ORIG" == "Sí" ]]; then
        rm "$file"
        echo -e "${YELLOW}[Info] Archivo original eliminado (-r activado).${NC}"
      else
        echo -e "${BLUE}[Info] Archivo original conservado.${NC}"
      fi
    else
      echo -e "${RED}[Fallo] Hubo un error al descomprimir '$file'. El original NO se ha borrado.${NC}"
    fi
    echo -e "------------------------------------------------------"
  done
}

# --- Ejecución Principal ---
if [[ "$MODE" == "compress" ]]; then
  do_compress
else
  do_decompress
fi
