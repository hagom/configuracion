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
    echo -e "${YELLOW}Herramienta '$tool' no encontrada. Instalando $package...${NC}"
    sudo apt update -y && sudo apt install -y "$package"
    [ $? -ne 0 ] && echo -e "${RED}Error al instalar $package.${NC}" && exit 1
  fi
}

# --- Ayuda ---
usage() {
  echo -e "${BLUE}Uso:${NC} $0 <formato> <archivo1> <archivo2> <carpeta1> ..."
  echo -e "Formatos: ${GREEN}gz, xz, bz2, zip, 7z${NC}"
  echo -e "Ejemplo: $0 7z documento.pdf fotos/ musica.mp3"
  exit 1
}

# Verificar que haya al menos formato y un archivo
if [ $# -lt 2 ]; then usage; fi

# El primer argumento es el formato, el resto son los archivos
FORMAT=$1
shift         # Elimina el primer argumento de la lista para quedarnos solo con los archivos
INPUTS=("$@") # El resto de argumentos se guardan en un array

# Nombre del archivo de salida basado en el primer elemento o fecha
OUTPUT_NAME="batch_archive_$(date +%Y%m%d_%H%M%S)"

# --- Validar que los archivos existan ---
for item in "${INPUTS[@]}"; do
  if [ ! -e "$item" ]; then
    echo -e "${RED}Error: El elemento '$item' no existe. Saltando...${NC}"
  fi
done

echo -e "${BLUE}Preparando compresión masiva en formato: ${YELLOW}$FORMAT${NC}"

# --- Proceso de Compresión ---
case $FORMAT in
gz)
  ensure_tool "pigz" "pigz"
  tar -cvf - "${INPUTS[@]}" | pigz -9 >"${OUTPUT_NAME}.tar.gz"
  ;;
xz)
  ensure_tool "xz" "xz-utils"
  tar -cvf - "${INPUTS[@]}" | xz -9e -T0 >"${OUTPUT_NAME}.tar.xz"
  ;;
bz2)
  ensure_tool "lbzip2" "lbzip2"
  tar -I lbzip2 -cvf "${OUTPUT_NAME}.tar.bz2" "${INPUTS[@]}"
  ;;
zip)
  ensure_tool "zip" "zip"
  zip -9 -r "${OUTPUT_NAME}.zip" "${INPUTS[@]}"
  ;;
7z)
  ensure_tool "7z" "p7zip-full"
  7z a -mx=9 -ms=on "${OUTPUT_NAME}.7z" "${INPUTS[@]}"
  ;;
*)
  echo -e "${RED}Formato no válido.${NC}"
  usage
  ;;
esac

# --- Reporte de resultados ---
if [ $? -eq 0 ]; then
  FINAL_SIZE=$(du -sh "${OUTPUT_NAME}.${FORMAT}" | cut -f1)
  echo -e "${GREEN}---------------------------------------"
  echo -e "¡Compresión masiva completada!"
  echo -e "Archivo creado: ${YELLOW}${OUTPUT_NAME}.${FORMAT}${NC}"
  echo -e "Tamaño final: ${YELLOW}$FINAL_SIZE${NC}"
  echo -e "${GREEN}---------------------------------------${NC}"
else
  echo -e "${RED}Hubo un error en el proceso de encolado/compresión.${NC}"
fi
