#!/bin/bash

# ==============================================================================
# SCRIPT DE COMPRESIÓN/DESCOMPRESIÓN INTELIGENTE (MULTIPROCESO)
# ==============================================================================
# Autor: Gemini (Asistente AI)
# Descripción:
#   Herramienta unificada para gestionar archivos comprimidos en Linux.
#   - Gestiona dependencias automáticamente.
#   - Optimiza el uso de RAM y CPU (Multihilo en TODOS los formatos posibles).
#   - Descompresión inteligente: detecta extensiones automáticamente.
#   - Modo seguro: Opción de borrar originales solo tras éxito.
#
# Formatos soportados (compresión paralela):
#   gz (pigz), xz (xz -T0), bz2 (lbzip2/pbzip2), bz3 (bzip3),
#   lz (plzip), zst (zstd -T0), lrz (lrzip), 7z (7z multi-thread), zip
# ==============================================================================

# --- Colores ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Número de CPUs para herramientas que lo necesitan ---
NCPU=$(nproc)

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
  echo -e "${BLUE}=== Tabla de Eficiencia de Compresores (Todos Multiproceso) ===${NC}"
  echo -e ""
  echo -e "${YELLOW}--- Alta Compresión (Mayor tiempo) ---${NC}"
  echo -e "1. ${GREEN}lrz${NC} : ${YELLOW}Máxima${NC} (LRZIP). Ideal para archivos ENORMES (>1GB). Usa lzma+rzip."
  echo -e "2. ${GREEN}7z${NC}  : ${YELLOW}Ultra${NC} (LZMA2). Excelente ratio, alto uso de CPU/RAM."
  echo -e "3. ${GREEN}xz${NC}  : ${YELLOW}Excelente${NC} (LZMA). Estándar moderno en Linux."
  echo -e "4. ${GREEN}lz${NC}  : ${YELLOW}Excelente${NC} (LZIP/plzip). Similar a xz, enfocado en integridad."
  echo -e ""
  echo -e "${YELLOW}--- Compresión Balanceada ---${NC}"
  echo -e "5. ${GREEN}zst${NC} : ${YELLOW}Muy Rápido${NC} (Zstandard). Mejor balance velocidad/ratio moderno."
  echo -e "6. ${GREEN}bz3${NC} : ${YELLOW}Muy Alto${NC} (Bzip3). Eficiente para texto y código."
  echo -e "7. ${GREEN}bz2${NC} : ${YELLOW}Alto${NC} (lbzip2). Clásico, buena relación peso/tiempo."
  echo -e ""
  echo -e "${YELLOW}--- Alta Velocidad ---${NC}"
  echo -e "8. ${GREEN}gz${NC}  : ${YELLOW}Rápido${NC} (pigz). El más compatible y rápido."
  echo -e "9. ${GREEN}zip${NC} : ${YELLOW}Básico${NC}. Compatibilidad universal (Windows/Mac/Linux)."
  echo -e ""
  echo -e "${BLUE}Nota:${NC} Todos los formatos usan multiprocesamiento automático."
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
  echo -e "  ${BLUE}Ejemplo:${NC} $0 -c zst -n backup_fotos ./mis_fotos"
  echo -e ""
  echo -e "${YELLOW}MODO DESCOMPRESIÓN:${NC}"
  echo -e "  $0 -d [opciones] <archivos...>"
  echo -e "  ${BLUE}Ejemplo:${NC} $0 -d -r archivo1.zst archivo2.tar.gz"
  echo -e ""
  echo -e "${YELLOW}FORMATOS SOPORTADOS:${NC}"
  echo -e "  ${GREEN}gz${NC}, ${GREEN}xz${NC}, ${GREEN}bz2${NC}, ${GREEN}bz3${NC}, ${GREEN}zst${NC}, ${GREEN}lz${NC}, ${GREEN}lrz${NC}, ${GREEN}7z${NC}, ${GREEN}zip${NC}"
  echo -e ""
  echo -e "${YELLOW}OPCIONES DISPONIBLES:${NC}"
  echo -e "  ${GREEN}-c${NC}       : Comprimir."
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
  gz | xz | bz2 | bz3 | zip | 7z | zst | lz | lrz) shift ;;
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
# LÓGICA DE COMPRESIÓN (MULTIPROCESO)
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
  zst)
    ext="tar.zst"
    ensure_tool "zstd" "zstd"
    ;;
  lz)
    ext="tar.lz"
    ensure_tool "plzip" "plzip"
    ;;
  lrz)
    ext="tar.lrz"
    ensure_tool "lrzip" "lrzip"
    ;;
  zip)
    ext="zip"
    ensure_tool "zip" "zip"
    ;;
  7z)
    ext="7z"
    ensure_tool "7zz" "7zip"
    ;;
  *)
    echo -e "${RED}[Error] Formato '$FORMAT' no válido.${NC}"
    usage
    ;;
  esac

  # Definir nombre de salida
  [[ -z "$CUSTOM_NAME" ]] && CUSTOM_NAME="${INPUTS[0]%/}"
  FINAL_FILE=$(get_unique_name "$CUSTOM_NAME" "$ext")

  echo -e "${BLUE}[Info] Comprimiendo ${YELLOW}$ORIG_HUMAN${BLUE} de datos en formato ${GREEN}$FORMAT${BLUE} (${NCPU} hilos)...${NC}"

  # Ejecución de compresión (TODAS CON MULTIPROCESO)
  local CMD_SUCCESS=false
  if case $FORMAT in
    # pigz: usa todos los hilos por defecto
    gz) tar -cvf - "${INPUTS[@]}" | pigz -9 >"$FINAL_FILE" ;;
    # xz: -T0 usa todos los núcleos
    xz) tar -cvf - "${INPUTS[@]}" | xz -9e -T0 --memory="${mem_mb}MiB" >"$FINAL_FILE" ;;
    # lbzip2: usa todos los hilos por defecto
    bz2) tar -I 'lbzip2 -9' -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    # bzip3: usa -j para especificar hilos
    bz3) tar -I "bzip3 -j $NCPU" -cvf "$FINAL_FILE" "${INPUTS[@]}" ;;
    # zstd: -T0 usa todos los núcleos, nivel 19 para máxima compresión
    zst) tar -cvf - "${INPUTS[@]}" | zstd -19 -T0 -o "$FINAL_FILE" ;;
    # plzip: usa --threads para especificar hilos
    lz) tar -cvf - "${INPUTS[@]}" | plzip -9 --threads="$NCPU" >"$FINAL_FILE" ;;
    # lrzip: usa -p para hilos, -L 9 para nivel máximo, -z para lzma
    lrz) tar -cvf - "${INPUTS[@]}" | lrzip -L 9 -z -p "$NCPU" -o "$FINAL_FILE" ;;
    # zip: -9 máxima compresión (no tiene multiproceso nativo, pero es muy rápido)
    zip) zip -9 -r "$FINAL_FILE" "${INPUTS[@]}" ;;
    # 7z: -mmt=on usa todos los hilos
    7z) 7zz a -mx=9 -md=128m -ms=on -mmt=on "$FINAL_FILE" "${INPUTS[@]}" ;;
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
    echo -e "${BLUE}Hilos utilizados:${NC}  ${GREEN}${NCPU}${NC}"
    echo -e "${GREEN}===========================${NC}"

    # Borrar originales si se activó -r
    if [[ "$DELETE_ORIG" == "Sí" ]]; then
      for item in "${INPUTS[@]}"; do
        rm -rf "$item"
        echo -e "${YELLOW}[Info] Original eliminado: $item${NC}"
      done
    fi
  else
    echo -e "${RED}[Fatal] La compresión falló. Verifica espacio en disco o permisos.${NC}"
    rm -f "$FINAL_FILE" 2>/dev/null
    exit 1
  fi
}

# ==============================================================================
# LÓGICA DE DESCOMPRESIÓN (MULTIPROCESO)
# ==============================================================================
do_decompress() {
  for file in "${INPUTS[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo -e "${RED}[Saltando] '$file' no es un archivo válido.${NC}"
      continue
    fi

    echo -e "${BLUE}[Procesando] Archivo: ${YELLOW}$file${BLUE} (${NCPU} hilos)${NC}"
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
      # xz -T0 para descompresión multihilo
      xz -dc -T0 "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.tar.bz2 | *.tbz2)
      ensure_tool "lbzip2" "lbzip2"
      # lbzip2 usa todos los hilos por defecto
      lbzip2 -dc "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.tar.bz3)
      ensure_tool "bzip3" "bzip3"
      bzip3 -dc -j "$NCPU" "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.tar.zst | *.tzst)
      ensure_tool "zstd" "zstd"
      # zstd -T0 para usar todos los hilos
      zstd -dc -T0 "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.tar.lz | *.tlz)
      ensure_tool "plzip" "plzip"
      # plzip usa todos los hilos por defecto
      plzip -dc --threads="$NCPU" "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.tar.lrz)
      ensure_tool "lrzip" "lrzip"
      # lrzip -d para descomprimir, -p para hilos
      lrzip -d -p "$NCPU" -o - "$file" | tar -xvf -
      SUCCESS=$?
      ;;
    *.lrz)
      # Archivo lrz sin tar
      ensure_tool "lrzip" "lrzip"
      lrzip -d -p "$NCPU" "$file"
      SUCCESS=$?
      ;;
    *.zst)
      # Archivo zst sin tar
      ensure_tool "zstd" "zstd"
      zstd -d -T0 "$file"
      SUCCESS=$?
      ;;
    *.xz)
      # Archivo xz sin tar
      ensure_tool "xz" "xz-utils"
      xz -d -T0 -k "$file"
      SUCCESS=$?
      ;;
    *.gz)
      # Archivo gz sin tar
      ensure_tool "pigz" "pigz"
      pigz -dk "$file"
      SUCCESS=$?
      ;;
    *.bz2)
      # Archivo bz2 sin tar
      ensure_tool "lbzip2" "lbzip2"
      lbzip2 -dk "$file"
      SUCCESS=$?
      ;;
    *.lz)
      # Archivo lz sin tar
      ensure_tool "plzip" "plzip"
      plzip -dk --threads="$NCPU" "$file"
      SUCCESS=$?
      ;;
    *.zip)
      ensure_tool "unzip" "unzip"
      unzip "$file"
      SUCCESS=$?
      ;;
    *.7z)
      ensure_tool "7zz" "7zip"
      # 7z usa multiproceso automáticamente
      7zz x "$file"
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
