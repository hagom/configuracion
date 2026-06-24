#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# COMPRESOR / DESCOMPRESOR UNIVERSAL (BASH) - v2.0
# ==============================================================================
# - Multiproceso en todos los formatos
# - Instalación batch de dependencias multi-distro
# - Logging a /var/log/compresor/
# - Modo test, dry-run, exclude, split
# - Detección inteligente de memoria RAM disponible
# ==============================================================================

# --- Configuración ---
LOG_DIR="/var/log/compresor"
MAX_LOGS=10
NCPU=$(nproc 2>/dev/null || echo 1)

# --- Colores ---
readonly GREEN='\033[0;32m' RED='\033[0;31m' YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m' BOLD='\033[1m' NC='\033[0m'

# --- Helper: convertir a minúsculas ---
_lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# --- Variables globales ---
MISSING_DEPS=()
EXCLUDE_PATTERNS=()
INPUTS=()
MODE=""
FORMAT=""
CUSTOM_NAME=""
DELETE_ORIG="No"
DRY_RUN="No"
TEST_MODE="No"
SPLIT_SIZE=""
INDIVIDUAL=""
LOG_FILE=""
PKG_MANAGER=""
PKG_UPDATE=""
PKG_INSTALL=""
SEVENZ_BIN=""
BZIP2_BIN=""
CLEANUP_FILE=""

# ==============================================================================
# FUNCIONES AUXILIARES
# ==============================================================================

# --- Detectar gestor de paquetes ---
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
        PKG_UPDATE="apt update -y"
        PKG_INSTALL="apt install -y"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="dnf check-update -y || true"
        PKG_INSTALL="dnf install -y"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
        PKG_UPDATE="yum check-update -y || true"
        PKG_INSTALL="yum install -y"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="pacman -Sy"
        PKG_INSTALL="pacman -S --noconfirm"
    elif command -v zypper &>/dev/null; then
        PKG_MANAGER="zypper"
        PKG_UPDATE="zypper refresh"
        PKG_INSTALL="zypper install -y"
    elif command -v apk &>/dev/null; then
        PKG_MANAGER="apk"
        PKG_UPDATE="apk update"
        PKG_INSTALL="apk add"
    fi
}

# --- Mapear herramienta a paquete según gestor ---
tool_to_package() {
    local tool=$1
    # Default: mismo nombre del tool (funciona en pacman, apk, dnf, yum)
    # Excepciones por distro
    case "${PKG_MANAGER}:${tool}" in
        apt:xz)     echo "xz-utils"   ;;
        apt:7z)     echo "p7zip-full" ;;
        dnf:7z|yum:7z|zypper:7z|apk:7z) echo "p7zip" ;;
        pacman:7z)  echo "7zip"       ;;
        *)          echo "$tool"      ;;
    esac
}

# --- Verificar sudo ---
check_sudo() {
    if [[ "$(id -u)" -eq 0 ]]; then
        return 0
    fi
    if ! command -v sudo &>/dev/null; then
        printf "${YELLOW}[Sistema] 'sudo' no está instalado. No se pueden instalar dependencias automáticamente.${NC}\n" >&2
        return 1
    fi
    if ! sudo -n true 2>/dev/null; then
        printf "${YELLOW}[Sistema] No se tienen permisos sudo sin contraseña.${NC}\n" >&2
        printf "${YELLOW}         Ejecuta con sudo o configura NOPASSWD en sudoers.${NC}\n" >&2
        return 1
    fi
    return 0
}

# --- Acumular dependencia faltante ---
ensure_tool() {
    local tool=$1
    local bin="${2:-$1}"
    shift 2 || true
    local alternatives=("$@")

    if command -v "$bin" &>/dev/null; then
        return 0
    fi
    for alt in "${alternatives[@]}"; do
        if command -v "$alt" &>/dev/null; then
            return 0
        fi
    done

    local pkg
    pkg=$(tool_to_package "$tool")
    for dep in "${MISSING_DEPS[@]}"; do
        [[ "$dep" == "$pkg" ]] && return 0
    done
    MISSING_DEPS+=("$pkg")
    printf "${YELLOW}[Sistema] Dependencia faltante: %s${NC}\n" "$pkg"
}

# --- Instalar todas las dependencias acumuladas en un solo comando ---
install_missing_deps() {
    [[ ${#MISSING_DEPS[@]} -eq 0 ]] && return 0

    printf "${YELLOW}[Sistema] Instalando dependencias: %s${NC}\n" "${MISSING_DEPS[*]}"

    if ! check_sudo; then
        printf "${RED}[Error] No se pueden instalar dependencias sin permisos.${NC}\n" >&2
        printf "${YELLOW}Instala manualmente: %s${NC}\n" "${MISSING_DEPS[*]}" >&2
        exit 1
    fi

    local -a install_cmd update_cmd
    if [[ "$(id -u)" -eq 0 ]]; then
        IFS=' ' read -ra install_cmd <<< "$PKG_INSTALL"
        IFS=' ' read -ra update_cmd <<< "$PKG_UPDATE"
    else
        install_cmd=(sudo)
        IFS=' ' read -ra tmp <<< "$PKG_INSTALL"
        install_cmd+=("${tmp[@]}")
        update_cmd=(sudo bash -c "$PKG_UPDATE")
    fi

    if ! "${install_cmd[@]}" "${MISSING_DEPS[@]}"; then
        printf "${YELLOW}[Sistema] Reintentando tras actualizar repositorios...${NC}\n"
        "${update_cmd[@]}"
        "${install_cmd[@]}" "${MISSING_DEPS[@]}"
    fi

    printf "${GREEN}[Sistema] Dependencias instaladas correctamente.${NC}\n"
}

# --- Registrar herramientas según formato de compresión ---
register_compress_tools() {
    case "$FORMAT" in
        gz)   ensure_tool pigz ;;
        xz)   ensure_tool xz ;;
        bz2)  ensure_tool "$BZIP2_BIN" "$BZIP2_BIN" pbzip2 ;;
        bz3)  ensure_tool bzip3 ;;
        zst)  ensure_tool zstd ;;
        lz)   ensure_tool plzip ;;
        lrz)  ensure_tool lrzip ;;
        zip)  ensure_tool zip ; ensure_tool 7z "$SEVENZ_BIN" ;;
        7z)   ensure_tool 7z "$SEVENZ_BIN" ;;
        tar)  ensure_tool tar ;;
    esac
}

# --- Registrar herramientas según extensión de archivo ---
register_decompress_tool() {
    local file=$1
    local f_lower
    f_lower=$(_lower "$file")
    case "$f_lower" in
        *.tar.gz|*.tgz)       ensure_tool pigz ;;
        *.tar.xz|*.txz)       ensure_tool xz ;;
        *.tar.bz2|*.tbz2)     ensure_tool "$BZIP2_BIN" "$BZIP2_BIN" pbzip2 ;;
        *.tar.bz3)            ensure_tool bzip3 ;;
        *.tar.zst|*.tzst)     ensure_tool zstd ;;
        *.tar.lz|*.tlz)       ensure_tool plzip ;;
        *.tar.lrz)            ensure_tool lrzip ;;
        *.lrz)                ensure_tool lrzip ;;
        *.zst)                ensure_tool zstd ;;
        *.xz)                 ensure_tool xz ;;
        *.gz)                 ensure_tool pigz ;;
        *.bz2)                ensure_tool "$BZIP2_BIN" "$BZIP2_BIN" pbzip2 ;;
        *.lz)                 ensure_tool plzip ;;
        *.zip)                ensure_tool unzip ;;
        *.7z)                 ensure_tool 7z "$SEVENZ_BIN" ;;
        *.tar)                ensure_tool tar ;;
    esac
}

# --- Obtener límite de memoria (70% de RAM disponible) ---
get_mem_limit() {
    local mem_kb

    if [[ -r /proc/meminfo ]]; then
        mem_kb=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    fi

    if [[ -z "$mem_kb" ]]; then
        mem_kb=$(free -k 2>/dev/null | awk '/^Mem:/{print $7}')
    fi

    if [[ -z "$mem_kb" ]]; then
        mem_kb=$(awk '/^MemFree:/{f=$2} /^Cached:/{c=$2} END{print f+c}' /proc/meminfo 2>/dev/null)
    fi

    if [[ -z "$mem_kb" || "$mem_kb" -le 0 ]]; then
        echo 1024
        return
    fi

    echo $((mem_kb * 70 / 100 / 1024))
}

# --- Formatear tamaño (fallback si no hay numfmt) ---
format_size() {
    local bytes=$1
    if command -v numfmt &>/dev/null; then
        numfmt --to=iec-i --suffix=B "$bytes" 2>/dev/null || echo "${bytes}B"
    else
        local units=("B" "KiB" "MiB" "GiB" "TiB" "PiB")
        local unit=0
        local size=$bytes
        while [[ $size -gt 1024 && $unit -lt 5 ]]; do
            size=$((size / 1024))
            unit=$((unit + 1))
        done
        echo "${size} ${units[$unit]}"
    fi
}

# --- Estimar tamaño descomprimido ---
estimate_uncompressed_size() {
    local file=$1
    local f_lower
    f_lower=$(_lower "$file")

    case "$f_lower" in
        *.gz|*.tgz)
            gzip -l -- "$file" 2>/dev/null | awk 'NR==2 {print $2}'
            return
            ;;
        *.xz|*.txz)
            xz -l --robot -- "$file" 2>/dev/null | awk -F'\t' '/^file/ && $5 ~ /^[0-9]+$/{print $5}'
            return
            ;;
        *.zst|*.tzst)
            zstd -l -- "$file" 2>/dev/null | awk '/^[[:space:]]*[0-9]+[[:space:]]/ && !/Frames/ && $5 ~ /^[0-9]+$/{sum+=$5} END{if(sum>0) print sum}'
            return
            ;;
        *.zip)
            unzip -l -- "$file" 2>/dev/null | tail -1 | awk '{print $1}'
            return
            ;;
        *.7z)
            "$SEVENZ_BIN" l -slt -- "$file" 2>/dev/null | awk '/^Size = / {sum+=$3} END {print int(sum)}'
            return
            ;;
        *.lrz)
            lrzip -i -- "$file" 2>/dev/null | awk '/Decompressed file size/{print $NF}'
            return
            ;;
        *.tar)
            stat -c%s -- "$file" 2>/dev/null
            return
            ;;
        *.bz2|*.tbz2|*.bz3|*.lz|*.tlz)
            stat -c%s -- "$file" 2>/dev/null | awk '{print $1 * 6}'
            return
            ;;
        *)
            stat -c%s -- "$file" 2>/dev/null | awk '{print $1 * 4}'
            return
            ;;
    esac
}

# --- Obtener bytes disponibles en directorio ---
_get_avail_bytes() {
    local dir=${1:-.} avail
    avail=$(df -B1 --output=avail "$dir" 2>/dev/null | awk 'NR==2 {print $1}' | tr -d ' ')
    [[ -z "$avail" || "$avail" == "avail" ]] && avail=$(df "$dir" 2>/dev/null | awk 'NR>1 {print int($4) * 1024}')
    echo "${avail:-0}"
}

# --- Verificar espacio disponible antes de descomprimir ---
check_decompress_space() {
    local file=$1
    local compressed_size uncomp_size est_size avail_bytes

    compressed_size=$(stat -c%s -- "$file" 2>/dev/null || echo 0)
    [[ "$compressed_size" -eq 0 ]] && return 0

    uncomp_size=$(estimate_uncompressed_size "$file")
    est_size=${uncomp_size:-$((compressed_size * 4))}
    avail_bytes=$(_get_avail_bytes ".")

    if [[ "$est_size" -gt "$avail_bytes" ]]; then
        printf "${RED}[Sin espacio] %s necesita ~%s, disponible %s. Saltando.${NC}\n" \
            "$file" "$(format_size "$est_size")" "$(format_size "$avail_bytes")" >&2
        return 1
    fi
    if [[ "$est_size" -gt "$((avail_bytes * 80 / 100))" ]]; then
        printf "${YELLOW}[Advertencia] %s necesita ~%s, espacio disponible %s (muy justo).${NC}\n" \
            "$file" "$(format_size "$est_size")" "$(format_size "$avail_bytes")" >&2
    fi
    return 0
}

# --- Test rápido de capa de compresión (interno, sin output) ---
_test_compression_layer() {
    local file=$1
    local f_lower
    f_lower=$(_lower "$file")
    case "$f_lower" in
        *.tar.gz|*.tgz|*.gz)           pigz -t -- "$file" 2>/dev/null ;;
        *.tar.xz|*.txz|*.xz)           xz -t -- "$file" 2>/dev/null ;;
        *.tar.bz2|*.tbz2|*.bz2)        "$BZIP2_BIN" -t -- "$file" 2>/dev/null ;;
        *.tar.bz3)                     bzip3 -t -- "$file" 2>/dev/null ;;
        *.tar.zst|*.tzst|*.zst)         zstd -t -- "$file" 2>/dev/null ;;
        *.tar.lz|*.tlz|*.lz)           plzip -t -- "$file" 2>/dev/null ;;
        *.tar.lrz|*.lrz)               lrzip -t -- "$file" 2>/dev/null ;;
        *.zip)                         unzip -t -- "$file" >/dev/null 2>&1 ;;
        *.7z)                          "$SEVENZ_BIN" t -- "$file" >/dev/null 2>&1 ;;
        *.tar)                         tar -tf "$file" >/dev/null 2>&1 ;;
        *)                             return 1 ;;
    esac
}

# --- Test de compresión pre-descompresión (con output) ---
_test_compress_layer() {
    local file=$1
    printf "${BLUE}[Verificando] %s...${NC} " "$file"
    if _test_compression_layer "$file"; then
        printf "${GREEN}[OK]${NC}\n"
        return 0
    else
        printf "${RED}[CORRUPTO] Saltando.${NC}\n" >&2
        return 1
    fi
}

# --- Generar nombre único de archivo ---
get_unique_name() {
    local base_name=$1 ext=$2 counter=1 final_name

    if [[ "$base_name" == *."$ext" ]]; then
        base_name="${base_name%.$ext}"
    fi

    final_name="${base_name}.${ext}"
    if [[ -e "$final_name" ]]; then
        while [[ -e "${base_name}_${counter}.${ext}" ]]; do
            counter=$((counter + 1))
        done
        final_name="${base_name}_${counter}.${ext}"
    fi
    echo "$final_name"
}

# --- Verificar espacio en disco ---
check_disk_space() {
    local needed=$1 dir=$2 available
    available=$(_get_avail_bytes "$dir")
    if [[ "$available" -lt "$needed" ]]; then
        printf "${RED}[Error] Espacio insuficiente en disco.${NC}\n" >&2
        printf "${YELLOW}  Necesario: %s${NC}\n" "$(format_size "$needed")" >&2
        printf "${YELLOW}  Disponible: %s${NC}\n" "$(format_size "$available")" >&2
        exit 1
    fi
}

# --- Configurar logging ---
setup_logging() {
    local log_dir="$LOG_DIR"
    if ! mkdir -p "$log_dir" 2>/dev/null; then
        log_dir="/tmp/compresor"
        mkdir -p "$log_dir" 2>/dev/null || true
    fi

    LOG_FILE="${log_dir}/compresor_$(date +%Y%m%d_%H%M%S).log"

    find "$log_dir" -name 'compresor_*.log' -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | tail -n +$((MAX_LOGS + 1)) | \
        while read -r _ file; do rm -f -- "$file" 2>/dev/null; done || true

    exec > >(tee -a "$LOG_FILE") 2>&1
}

# --- Limpieza por señal ---
cleanup() {
    if [[ -n "${CLEANUP_FILE:-}" && -f "${CLEANUP_FILE:-}" ]]; then
        printf "\n${YELLOW}[Sistema] Interrupción detectada. Limpiando archivo incompleto: %s${NC}\n" "$CLEANUP_FILE"
        rm -f -- "$CLEANUP_FILE" 2>/dev/null
    fi
    exit 1
}

# --- Listar compresores ---
list_compressors() {
    printf "${BLUE}=== Tabla de Eficiencia de Compresores (Todos Multiproceso) ===${NC}\n"
    printf "\n"
    printf "${YELLOW}--- Alta Compresión (Mayor tiempo) ---${NC}\n"
    printf "1. ${GREEN}lrz${NC} : ${YELLOW}Máxima${NC} (LRZIP). Ideal para archivos ENORMES (>1GB). Usa lzma+rzip.\n"
    printf "2. ${GREEN}7z${NC}  : ${YELLOW}Ultra${NC} (LZMA2). Excelente ratio, alto uso de CPU/RAM.\n"
    printf "3. ${GREEN}xz${NC}  : ${YELLOW}Excelente${NC} (LZMA). Estándar moderno en Linux.\n"
    printf "4. ${GREEN}lz${NC}  : ${YELLOW}Excelente${NC} (LZIP/plzip). Similar a xz, enfocado en integridad.\n"
    printf "\n"
    printf "${YELLOW}--- Compresión Balanceada ---${NC}\n"
    printf "5. ${GREEN}zst${NC} : ${YELLOW}Muy Rápido${NC} (Zstandard). Mejor balance velocidad/ratio moderno.\n"
    printf "6. ${GREEN}bz3${NC} : ${YELLOW}Muy Alto${NC} (Bzip3). Eficiente para texto y código.\n"
    printf "7. ${GREEN}bz2${NC} : ${YELLOW}Alto${NC} (lbzip2). Clásico, buena relación peso/tiempo.\n"
    printf "\n"
    printf "${YELLOW}--- Alta Velocidad ---${NC}\n"
    printf "8. ${GREEN}gz${NC}  : ${YELLOW}Rápido${NC} (pigz). El más compatible y rápido.\n"
    printf "9. ${GREEN}zip${NC} : ${YELLOW}Básico${NC}. Compatibilidad universal (Windows/Mac/Linux).\n"
    printf "\n"
    printf "${YELLOW}--- Sin compresión ---${NC}\n"
    printf "10. ${GREEN}tar${NC} : Solo empaquetado sin compresión.\n"
    printf "\n"
    printf "${BLUE}Nota:${NC} Todos los formatos usan multiprocesamiento automático.\n"
    exit 0
}

# --- Ayuda ---
usage() {
    printf "${BLUE}======================================================${NC}\n"
    printf "${GREEN}      COMPRESOR / DESCOMPRESOR UNIVERSAL (BASH)      ${NC}\n"
    printf "${BLUE}======================================================${NC}\n"
    printf "\n"
    printf "${YELLOW}MODO COMPRESIÓN:${NC}\n"
    printf "  %s -c <formato> [opciones] <archivos/carpetas...>\n" "$0"
    printf "  ${BLUE}Ejemplo (agrupar):${NC} %s -c zst -n backup_fotos ./mis_fotos\n" "$0"
    printf "  ${BLUE}Ejemplo (individual):${NC} %s -c gz -i file1.txt file2.txt\n" "$0"
    printf "\n"
    printf "${YELLOW}MODO DESCOMPRESIÓN:${NC}\n"
    printf "  %s -d [opciones] <archivos...>\n" "$0"
    printf "  ${BLUE}Ejemplo:${NC} %s -d archivo1.zst archivo2.tar.gz\n" "$0"
    printf "\n"
    printf "${YELLOW}MODO TEST:${NC}\n"
    printf "  %s -t <archivos...>\n" "$0"
    printf "  ${BLUE}Ejemplo:${NC} %s -t archivo.tar.zst archivo.zip\n" "$0"
    printf "\n"
    printf "${YELLOW}OPCIONES:${NC}\n"
    printf "  ${GREEN}-c <fmt>${NC}    : Comprimir (formatos: gz, xz, bz2, bz3, zst, lz, lrz, zip, 7z, tar)\n"
    printf "  ${GREEN}-d${NC}          : Descomprimir (detecta formato automáticamente)\n"
    printf "  ${GREEN}-t${NC}          : Verificar integridad de archivos comprimidos\n"
    printf "  ${GREEN}-r${NC}          : ${RED}Borrar original${NC} al finalizar (solo si no hubo errores)\n"
    printf "  ${GREEN}-n nombre${NC}   : Nombre personalizado para el archivo de salida\n"
    printf "  ${GREEN}-l${NC}          : Ver tabla comparativa de compresores\n"
    printf "  ${GREEN}-h${NC}          : Mostrar esta ayuda\n"
    printf "  ${GREEN}--dry-run${NC}   : Previsualizar sin ejecutar\n"
    printf "  ${GREEN}--exclude PAT${NC}: Excluir patrones (ej: --exclude=.git --exclude=*.log)\n"
    printf "  ${GREEN}--split TAM${NC}  : Dividir en volúmenes (ej: --split=100M, --split=1G)\n"
    printf "  ${GREEN}-i${NC}          : Comprimir cada archivo por separado en vez de agruparlos\n"
    printf "  ${GREEN}--install${NC}    : Copiar script a /usr/local/bin/compresor\n"
    printf "  ${GREEN}--uninstall${NC}  : Eliminar /usr/local/bin/compresor\n"
    printf "\n"
}

# ==============================================================================
# LÓGICA DE COMPRESIÓN — Núcleo (comprime un conjunto de archivos en UN archive)
# ==============================================================================
_compress_items() {
    local -a items=("$@")
    [[ ${#items[@]} -eq 0 ]] && return 1

    local ext mem_mb FINAL_FILE TOTAL_ORIG_BYTES=0 ORIG_HUMAN
    mem_mb=$(get_mem_limit)

    case $FORMAT in
        gz)   ext="tar.gz"   ;;
        xz)   ext="tar.xz"   ;;
        bz2)  ext="tar.bz2"  ;;
        bz3)  ext="tar.bz3"  ;;
        zst)  ext="tar.zst"  ;;
        lz)   ext="tar.lz"   ;;
        lrz)  ext="tar.lrz"  ;;
        zip)  ext="zip"      ;;
        7z)   ext="7z"       ;;
        tar)  ext="tar"      ;;
    esac

    local base_name
    if [[ "$INDIVIDUAL" == "Sí" || -z "$CUSTOM_NAME" ]]; then
        base_name="${items[0]%/}"
    else
        base_name="$CUSTOM_NAME"
    fi
    FINAL_FILE=$(get_unique_name "$base_name" "$ext")

    if [[ "$DRY_RUN" == "Sí" ]]; then
        printf "${YELLOW}[DRY-RUN] Comando:${NC}\n"
        case $FORMAT in
            gz)  printf "  tar -cvf - %s | pigz -9 > %s\n" "${items[*]}" "$FINAL_FILE" ;;
            xz)  printf "  tar -cvf - %s | xz -9e -T0 --memory=%sMiB > %s\n" "${items[*]}" "$mem_mb" "$FINAL_FILE" ;;
            bz2) printf "  tar -cvf - %s | %s -9 > %s\n" "${items[*]}" "$BZIP2_BIN" "$FINAL_FILE" ;;
            bz3) printf "  tar -cvf - %s | bzip3 -j %s > %s\n" "${items[*]}" "$NCPU" "$FINAL_FILE" ;;
            zst) printf "  tar -cvf - %s | zstd -19 -T0 -o %s\n" "${items[*]}" "$FINAL_FILE" ;;
            lz)  printf "  tar -cvf - %s | plzip -9 --threads=%s > %s\n" "${items[*]}" "$NCPU" "$FINAL_FILE" ;;
            lrz) printf "  tar -cvf - %s | lrzip -L 9 -z -p %s -o %s\n" "${items[*]}" "$NCPU" "$FINAL_FILE" ;;
            zip) printf "  %s a -tzip -mx=9 -mmt=on %s %s\n" "$SEVENZ_BIN" "$FINAL_FILE" "${items[*]}" ;;
            7z)  printf "  %s a -mx=9 -md=128m -ms=on -mmt=on %s %s\n" "$SEVENZ_BIN" "$FINAL_FILE" "${items[*]}" ;;
            tar) printf "  tar -cvf %s %s\n" "$FINAL_FILE" "${items[*]}" ;;
        esac
        if [[ -n "$SPLIT_SIZE" ]]; then
            printf "  split -b %s %s %s.part.\n" "$SPLIT_SIZE" "$FINAL_FILE" "$FINAL_FILE"
        fi
        printf "${GREEN}[DRY-RUN] Modo simulación activado. No se ejecutó nada.${NC}\n"
        exit 0
    fi

    for item in "${items[@]}"; do
        if [[ ! -e "$item" ]]; then
            printf "${RED}[Error] Archivo/Carpeta no encontrado: %s${NC}\n" "$item" >&2
            return 1
        fi
        TOTAL_ORIG_BYTES=$((TOTAL_ORIG_BYTES + $(du -sb -- "$item" | cut -f1)))
    done
    ORIG_HUMAN=$(format_size "$TOTAL_ORIG_BYTES")

    check_disk_space $((TOTAL_ORIG_BYTES * 20 / 100)) "$(dirname "$FINAL_FILE" 2>/dev/null || echo .)"

    printf "${BLUE}[Info] Comprimiendo ${YELLOW}%s${BLUE} de datos en formato ${GREEN}%s${BLUE} (%s hilos)...${NC}\n" \
        "$ORIG_HUMAN" "$FORMAT" "$NCPU"

    CLEANUP_FILE="$FINAL_FILE"

    local -a tar_exclude
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        tar_exclude+=(--exclude="$pattern")
    done

    local pv_cmd="cat"
    if command -v pv &>/dev/null; then
        pv_cmd="pv -f -s $TOTAL_ORIG_BYTES 2>&1"
    fi

    local CMD_EXIT=0
    case $FORMAT in
        gz)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | pigz -9 > "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        xz)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | xz -9e -T0 --memory="${mem_mb}MiB" > "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        bz2)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | "$BZIP2_BIN" -9 > "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        bz3)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | bzip3 -j "$NCPU" > "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        zst)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | zstd -19 -T0 -o "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        lz)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | plzip -9 --threads="$NCPU" > "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        lrz)
            tar "${tar_exclude[@]}" -cvf - -- "${items[@]}" | eval "$pv_cmd" | lrzip -L 9 -z -p "$NCPU" -o "$FINAL_FILE" || CMD_EXIT=$?
            ;;
        zip)
            "$SEVENZ_BIN" a -tzip -mx=9 -mmt=on "$FINAL_FILE" -- "${items[@]}" || CMD_EXIT=$?
            ;;
        7z)
            "$SEVENZ_BIN" a -mx=9 -md=128m -ms=on -mmt=on "$FINAL_FILE" -- "${items[@]}" || CMD_EXIT=$?
            ;;
        tar)
            tar "${tar_exclude[@]}" -cvf "$FINAL_FILE" -- "${items[@]}" || CMD_EXIT=$?
            ;;
    esac

    if [[ $CMD_EXIT -eq 0 && -f "$FINAL_FILE" ]]; then
        CLEANUP_FILE=""

        if [[ -n "$SPLIT_SIZE" ]]; then
            printf "${BLUE}[Info] Dividiendo archivo en volúmenes de %s...${NC}\n" "$SPLIT_SIZE"
            split -b "$SPLIT_SIZE" -- "$FINAL_FILE" "${FINAL_FILE}.part."
            rm -f -- "$FINAL_FILE"
            printf "${GREEN}[OK] Archivo dividido en %s.part.aa, %s.part.ab, ...${NC}\n" "$FINAL_FILE" "$FINAL_FILE"
            FINAL_FILE="${FINAL_FILE}.part.aa"
        fi

        local FINAL_SIZE FINAL_BYTES PERCENTAGE
        FINAL_SIZE=$(du -sh -- "$FINAL_FILE" 2>/dev/null | cut -f1)
        FINAL_BYTES=$(du -sb -- "$FINAL_FILE" 2>/dev/null | cut -f1)

        PERCENTAGE="0.00"
        if [[ "$TOTAL_ORIG_BYTES" -gt 0 && -n "$FINAL_BYTES" && "$FINAL_BYTES" -gt 0 ]]; then
            PERCENTAGE=$(awk -v orig="$TOTAL_ORIG_BYTES" -v final="$FINAL_BYTES" 'BEGIN {printf "%.2f", (orig - final) / orig * 100}')
        fi

        printf "\n${GREEN}=== Reporte de Compresión ===${NC}\n"
        printf "${BLUE}Archivo Salida:${NC}    ${YELLOW}%s${NC}\n" "$FINAL_FILE"
        printf "${BLUE}Tamaño Original:${NC}   ${RED}%s${NC}\n" "$ORIG_HUMAN"
        printf "${BLUE}Tamaño Final:${NC}      ${GREEN}%s${NC}\n" "$FINAL_SIZE"
        printf "${BLUE}Ahorro de espacio:${NC} ${GREEN}%s%%${NC}\n" "$PERCENTAGE"
        printf "${BLUE}Hilos utilizados:${NC}  ${GREEN}%s${NC}\n" "$NCPU"
        printf "${GREEN}===========================${NC}\n"

        if [[ "$DELETE_ORIG" == "Sí" ]]; then
            for item in "${items[@]}"; do
                rm -rf -- "$item"
                printf "${YELLOW}[Info] Original eliminado: %s${NC}\n" "$item"
            done
        fi

        if [[ "$TEST_MODE" == "Sí" ]]; then
            do_test_file "$FINAL_FILE"
        fi
        return 0
    else
        printf "${RED}[Fatal] La compresión falló. Verifica espacio en disco o permisos.${NC}\n" >&2
        rm -f -- "$FINAL_FILE" 2>/dev/null
        return 1
    fi
}

# ==============================================================================
# LÓGICA DE COMPRESIÓN — Dispatcher (individual o bundle)
# ==============================================================================
do_compress() {
    if [[ "$INDIVIDUAL" == "Sí" && ${#INPUTS[@]} -gt 1 ]]; then
        local has_error=0
        for item in "${INPUTS[@]}"; do
            printf "${BLUE}══════════════════════════════════════════════${NC}\n"
            printf "${BLUE}  Archivo: ${YELLOW}%s${NC}\n" "$item"
            printf "${BLUE}══════════════════════════════════════════════${NC}\n"
            _compress_items "$item" || has_error=1
        done
        exit $has_error
    else
        _compress_items "${INPUTS[@]}" || exit 1
    fi
}

# ==============================================================================
# LÓGICA DE DESCOMPRESIÓN
# ==============================================================================
do_decompress() {
    # Verificación de espacio TOTAL antes de empezar
    local total_compressed=0 total_needed=0 avail_bytes
    for f in "${INPUTS[@]}"; do
        [[ ! -f "$f" ]] && continue
        local c_size u_size
        c_size=$(stat -c%s -- "$f" 2>/dev/null || echo 0)
        u_size=$(estimate_uncompressed_size "$f")
        u_size=${u_size:-$((c_size * 4))}
        total_compressed=$((total_compressed + c_size))
        total_needed=$((total_needed + u_size))
    done

    avail_bytes=$(_get_avail_bytes ".")

    printf "${BLUE}══════════════════════════════════════════════${NC}\n"
    printf "${BLUE}  Verificación de espacio para descompresión${NC}\n"
    printf "${BLUE}══════════════════════════════════════════════${NC}\n"
    printf "${BLUE}Archivos a procesar:${NC}  %s\n" "${#INPUTS[@]}"
    printf "${BLUE}Tamaño comprimido:${NC}   %s\n" "$(format_size "$total_compressed")"
    printf "${BLUE}Tamaño final est.:${NC}   %s\n" "$(format_size "$total_needed")"
    printf "${BLUE}Espacio disponible:${NC}  %s\n" "$(format_size "$avail_bytes")"

    if [[ $total_needed -gt $avail_bytes ]]; then
        printf "${RED}[Error] Espacio insuficiente. Necesitas ~%s, hay %s. Abortando.${NC}\n" \
            "$(format_size "$total_needed")" "$(format_size "$avail_bytes")" >&2
        exit 1
    fi
    if [[ $total_needed -gt $((avail_bytes * 80 / 100)) ]]; then
        printf "${YELLOW}[Advertencia] Espacio muy justo: %s disponible para ~%s necesarios.${NC}\n" \
            "$(format_size "$avail_bytes")" "$(format_size "$total_needed")" >&2
    fi
    printf "${GREEN}[OK] Espacio suficiente.${NC}\n"
    printf '%s\n' "------------------------------------------------------"

    for file in "${INPUTS[@]}"; do
        if [[ ! -f "$file" ]]; then
            printf "${RED}[Saltando] '%s' no es un archivo válido.${NC}\n" "$file" >&2
            continue
        fi

        # Test de integridad previo
        if ! _test_compress_layer "$file"; then
            continue
        fi

        # Verificar espacio disponible por archivo (red de seguridad)
        if ! check_decompress_space "$file"; then
            continue
        fi

        printf "${BLUE}[Procesando] Archivo: ${YELLOW}%s${BLUE} (%s hilos)${NC}\n" "$file" "$NCPU"

        local SUCCESS=0
        local f_lower
        f_lower=$(_lower "$file")

        case "$f_lower" in
            *.tar.gz|*.tgz)
                pigz -dc -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.tar.xz|*.txz)
                xz -dc -T0 -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.tar.bz2|*.tbz2)
                "$BZIP2_BIN" -dc -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.tar.bz3)
                bzip3 -dc -j "$NCPU" -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.tar.zst|*.tzst)
                zstd -dc -T0 -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.tar.lz|*.tlz)
                plzip -dc --threads="$NCPU" -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.tar.lrz)
                lrzip -d -p "$NCPU" -o - -- "$file" | tar -xvf - || SUCCESS=$?
                ;;
            *.lrz)
                lrzip -d -k -p "$NCPU" -- "$file" || SUCCESS=$?
                ;;
            *.zst)
                zstd -d -T0 -- "$file" || SUCCESS=$?
                ;;
            *.xz)
                xz -d -T0 -k -- "$file" || SUCCESS=$?
                ;;
            *.gz)
                pigz -dk -- "$file" || SUCCESS=$?
                ;;
            *.bz2)
                "$BZIP2_BIN" -dk -- "$file" || SUCCESS=$?
                ;;
            *.lz)
                plzip -dk --threads="$NCPU" -- "$file" || SUCCESS=$?
                ;;
            *.zip)
                unzip -o -- "$file" || SUCCESS=$?
                ;;
            *.7z)
                "$SEVENZ_BIN" x -- "$file" || SUCCESS=$?
                ;;
            *.tar)
                tar -xvf "$file" || SUCCESS=$?
                ;;
            *)
                printf "${RED}[Error] Formato desconocido o no soportado para: %s${NC}\n" "$file" >&2
                SUCCESS=1
                ;;
        esac

        if [[ $SUCCESS -eq 0 ]]; then
            printf "${GREEN}[Éxito] Archivo descomprimido correctamente.${NC}\n"
            if [[ "$DELETE_ORIG" == "Sí" ]]; then
                rm -f -- "$file"
                printf "${YELLOW}[Info] Archivo original eliminado (-r activado).${NC}\n"
            else
                printf "${BLUE}[Info] Archivo original conservado.${NC}\n"
            fi
        else
            printf "${RED}[Fallo] Error al descomprimir '%s'. El original NO se ha borrado.${NC}\n" "$file" >&2
        fi
        printf '%s\n' "------------------------------------------------------"
    done
}

# ==============================================================================
# LÓGICA DE TEST DE INTEGRIDAD
# ==============================================================================
do_test_file() {
    local file=$1 f_lower
    f_lower=$(_lower "$file")

    printf "${BLUE}[Test] Verificando integridad: ${YELLOW}%s${NC}... " "$file"

    # Test capa de compresión
    if ! _test_compression_layer "$file"; then
        printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"
        return 1
    fi

    # Para .tar.*: test extra de integridad del tar via pipe-through
    case "$f_lower" in
        *.tar.gz|*.tgz)       pigz -dc -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar.xz|*.txz)       xz -dc -T0 -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar.bz2|*.tbz2)     "$BZIP2_BIN" -dc -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar.bz3)            bzip3 -dc -j "$NCPU" -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar.zst|*.tzst)     zstd -dc -T0 -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar.lz|*.tlz)       plzip -dc --threads="$NCPU" -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar.lrz)            lrzip -d -p "$NCPU" -o - -- "$file" 2>/dev/null | tar -t >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
        *.tar)                tar -tf "$file" >/dev/null 2>&1 || { printf "${RED}[CORRUPTO O INVÁLIDO]${NC}\n"; return 1; } ;;
    esac

    printf "${GREEN}[OK]${NC}\n"
    return 0
}

do_test() {
    local has_errors=0
    for file in "${INPUTS[@]}"; do
        if [[ ! -f "$file" ]]; then
            printf "${RED}[Saltando] '%s' no es un archivo válido.${NC}\n" "$file" >&2
            has_errors=1
            continue
        fi
        do_test_file "$file" || has_errors=1
    done
    exit $has_errors
}

# ==============================================================================
# PROCESAMIENTO DE ARGUMENTOS
# ==============================================================================
# Detectar binarios antes de parsear argumentos
if command -v 7zz &>/dev/null; then SEVENZ_BIN="7zz"
elif command -v 7z &>/dev/null; then SEVENZ_BIN="7z"
elif command -v 7za &>/dev/null; then SEVENZ_BIN="7za"
else SEVENZ_BIN="7z"; fi

if command -v lbzip2 &>/dev/null; then BZIP2_BIN="lbzip2"
elif command -v pbzip2 &>/dev/null; then BZIP2_BIN="pbzip2"
else BZIP2_BIN="lbzip2"; fi

detect_pkg_manager

PARSED_ARGS=$(getopt -o 'c:dhrn:lti' -l 'help,dry-run,exclude:,split:,test,individual,install,uninstall' -- "$@") || { usage; exit 1; }
eval set -- "$PARSED_ARGS"

while true; do
    case "$1" in
        -c)
            FORMAT="$2"
            MODE="compress"
            shift 2
            ;;
        -d)
            MODE="decompress"
            shift
            ;;
        -t|--test)
            MODE="test"
            shift
            ;;
        -r)
            DELETE_ORIG="Sí"
            shift
            ;;
        -n)
            CUSTOM_NAME="$2"
            shift 2
            ;;
        -l)
            list_compressors
            ;;
        -h|--help)
            usage; exit 0
            ;;
        --dry-run)
            DRY_RUN="Sí"
            shift
            ;;
        --exclude)
            EXCLUDE_PATTERNS+=("$2")
            shift 2
            ;;
        --split)
            SPLIT_SIZE="$2"
            shift 2
            ;;
        -i|--individual)
            INDIVIDUAL="Sí"
            shift
            ;;
        --install)
            SCRIPT_SRC=$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s' "$0")
            DEST="/usr/local/bin/compresor"
            DIR=$(dirname "$DEST")
            if [[ -w "$DIR" ]]; then
                install -m 755 "$SCRIPT_SRC" "$DEST"
            else
                sudo install -m 755 "$SCRIPT_SRC" "$DEST"
            fi
            printf "${GREEN}[OK] Script instalado en %s${NC}\n" "$DEST"
            exit 0
            ;;
        --uninstall)
            DEST="/usr/local/bin/compresor"
            if [[ -f "$DEST" ]]; then
                if [[ -w "$(dirname "$DEST")" ]]; then
                    rm -f "$DEST"
                else
                    sudo rm -f "$DEST"
                fi
                printf "${GREEN}[OK] Eliminado: %s${NC}\n" "$DEST"
            else
                printf "${YELLOW}[Info] No existe: %s${NC}\n" "$DEST"
            fi
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            usage; exit 1
            ;;
    esac
done

INPUTS=("$@")

# Normalizar inputs que empiezan con - para que no se interpreten como opciones
for i in "${!INPUTS[@]}"; do
    if [[ "${INPUTS[$i]}" == -* ]]; then
        INPUTS[$i]="./${INPUTS[$i]}"
    fi
done

# --- Validaciones ---
if [[ -z "$MODE" ]]; then
    printf "${RED}[Error] Debes especificar un modo de operación (-c, -d, -t).${NC}\n" >&2
    usage; exit 1
fi

if [[ "$MODE" == "compress" ]]; then
    if [[ -z "$FORMAT" ]]; then
        printf "${RED}[Error] Falta el formato de compresión.${NC}\n" >&2
        usage; exit 1
    fi
    if [[ ${#INPUTS[@]} -eq 0 ]]; then
        printf "${RED}[Error] No se especificaron archivos/carpetas para comprimir.${NC}\n" >&2
        usage; exit 1
    fi
fi

if [[ "$MODE" != "compress" && ${#INPUTS[@]} -eq 0 ]]; then
    printf "${RED}[Error] No se especificaron archivos para procesar.${NC}\n" >&2
    usage; exit 1
fi

# --- Registrar y instalar dependencias ---
if [[ "$MODE" == "compress" ]]; then
    register_compress_tools
else
    for file in "${INPUTS[@]}"; do
        register_decompress_tool "$file"
    done
fi

install_missing_deps

# --- Configurar logging ---
setup_logging
trap cleanup INT TERM

# --- Ejecución principal ---
case "$MODE" in
    compress)
        do_compress
        ;;
    decompress)
        do_decompress
        ;;
    test)
        do_test
        ;;
esac
