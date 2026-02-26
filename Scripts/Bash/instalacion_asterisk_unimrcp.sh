#!/bin/bash
###############################################################################
# Script de Instalación: Asterisk 22 LTS + UniMRCP 1.8.0
# Descripción: Compila e instala Asterisk 22 LTS desde fuente con todos los
#              codecs disponibles para la arquitectura del sistema, e integra
#              UniMRCP (core + módulos Asterisk) para soporte MRCP.
# Uso:         sudo bash instalacion_asterisk_unimrcp.sh
# Requisitos:  Debian 12/13 o derivado, acceso a internet, privilegios root.
# Fecha:       2026-02-26
###############################################################################

set -euo pipefail

# ========================== VARIABLES DE CONFIGURACIÓN =======================
ASTERISK_VERSION="22.8.2"
UNIMRCP_VERSION="1.8.0"
ASTERISK_UNIMRCP_VERSION="1.10.0"
ASTERISK_USER="asterisk"
ASTERISK_GROUP="asterisk"
SRC_DIR="/usr/src"
LOCAL_IP=$(hostname -I | awk '{print $1}')

# ========================== FUNCIONES AUXILIARES =============================
log_info()  { echo -e "\n\e[1;34m[INFO]\e[0m  $1"; }
log_ok()    { echo -e "\e[1;32m[OK]\e[0m    $1"; }
log_warn()  { echo -e "\e[1;33m[WARN]\e[0m  $1"; }
log_error() { echo -e "\e[1;31m[ERROR]\e[0m $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root (sudo)."
        exit 1
    fi
}

detect_arch() {
    ARCH=$(uname -m)
    log_info "Arquitectura detectada: $ARCH"
    if [[ "$ARCH" == "x86_64" ]]; then
        IS_X86=true
    else
        IS_X86=false
    fi
}

# ========================== PASO 1: PREPARACIÓN DEL SISTEMA ==================
install_dependencies() {
    log_info "Paso 1: Actualizando sistema e instalando dependencias..."

    apt update && apt upgrade -y

    # Herramientas de compilación
    apt install -y \
        build-essential wget curl git pkg-config python3 unzip \
        autoconf automake libtool

    # Librerías de desarrollo para Asterisk
    apt install -y \
        libssl-dev libncurses5-dev libnewt-dev libxml2-dev libsqlite3-dev \
        uuid-dev libjansson-dev libedit-dev libsrtp2-dev libasound2-dev \
        libradcli-dev

    # Librerías de codecs
    apt install -y \
        libopus-dev libopusfile-dev libgsm1-dev libspeex-dev libspeexdsp-dev \
        libogg-dev libvorbis-dev libcodec2-dev

    # Dependencias para UniMRCP
    apt install -y \
        libapr1-dev libaprutil1-dev libexpat1-dev libsofia-sip-ua-dev

    log_ok "Dependencias instaladas correctamente."
}

# ========================== PASO 2: COMPILAR ASTERISK ========================
compile_asterisk() {
    log_info "Paso 2: Descargando y compilando Asterisk $ASTERISK_VERSION..."

    cd "$SRC_DIR"

    if [[ ! -d "asterisk-${ASTERISK_VERSION}" ]]; then
        wget -q "https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz"
        tar -xzf "asterisk-${ASTERISK_VERSION}.tar.gz"
    else
        log_warn "Directorio asterisk-${ASTERISK_VERSION} ya existe, se reutilizará."
    fi

    cd "asterisk-${ASTERISK_VERSION}"

    # Instalar prerrequisitos dinámicos
    contrib/scripts/install_prereq install

    # Configurar con jansson y pjproject integrados
    ./configure --with-jansson-bundled --with-pjproject-bundled

    # Limpiar selección previa
    make menuselect-tree

    # Habilitar todos los codecs y formatos por software
    menuselect/menuselect \
        --enable CORE-SOUNDS-ES-ULAW \
        --enable codec_a_mu \
        --enable codec_adpcm \
        --enable codec_alaw \
        --enable codec_codec2 \
        --enable codec_g722 \
        --enable codec_g726 \
        --enable codec_gsm \
        --enable codec_ilbc \
        --enable codec_lpc10 \
        --enable codec_resample \
        --enable codec_speex \
        --enable codec_ulaw \
        --enable format_g719 \
        --enable format_g726 \
        --enable format_gsm \
        --enable format_h263 \
        --enable format_h264 \
        --enable format_ilbc \
        --enable format_mp3 \
        --enable format_ogg_speex \
        --enable format_ogg_vorbis \
        --enable format_pcm \
        --enable format_siren14 \
        --enable format_siren7 \
        --enable format_sln \
        --enable format_vox \
        --enable format_wav \
        --enable format_wav_gsm \
        menuselect.makeopts

    # Deshabilitar codecs que requieren blobs binarios x86 (no disponibles en ARM)
    if [[ "$IS_X86" == false ]]; then
        log_warn "Arquitectura no x86 detectada. Deshabilitando codecs binarios..."
        menuselect/menuselect \
            --disable codec_opus \
            --disable codec_silk \
            --disable codec_siren7 \
            --disable codec_siren14 \
            --disable codec_g729a \
            menuselect.makeopts
    fi

    # Compilar e instalar
    NPROC=$(nproc)
    log_info "Compilando Asterisk con $NPROC núcleos..."
    make -j"$NPROC"
    make install
    make samples
    make config

    # Instalar headers para módulos externos (UniMRCP, etc.)
    make install-headers

    log_ok "Asterisk $ASTERISK_VERSION compilado e instalado."
}

# ========================== PASO 3: CONFIGURAR SERVICIO ======================
configure_asterisk_service() {
    log_info "Paso 3: Configurando usuario y servicio de Asterisk..."

    # Crear usuario del sistema
    if ! id "$ASTERISK_USER" &>/dev/null; then
        adduser --system --group --home /var/lib/asterisk \
            --no-create-home --gecos "Asterisk PBX" "$ASTERISK_USER"
    fi

    # Configurar asterisk.conf para ejecutar como usuario asterisk
    sed -i "s/^;runuser =.*/runuser = ${ASTERISK_USER}/" /etc/asterisk/asterisk.conf
    sed -i "s/^;rungroup =.*/rungroup = ${ASTERISK_GROUP}/" /etc/asterisk/asterisk.conf

    # Ajustar permisos
    chown -R "$ASTERISK_USER:$ASTERISK_GROUP" /etc/asterisk
    chown -R "$ASTERISK_USER:$ASTERISK_GROUP" /var/lib/asterisk
    chown -R "$ASTERISK_USER:$ASTERISK_GROUP" /var/log/asterisk
    chown -R "$ASTERISK_USER:$ASTERISK_GROUP" /var/spool/asterisk
    chown -R "$ASTERISK_USER:$ASTERISK_GROUP" /var/run/asterisk 2>/dev/null || true

    # Corregir path de RADIUS (radcli vs radiusclient-ng)
    if [[ -d /etc/radcli ]] && [[ ! -e /etc/radiusclient-ng ]]; then
        ln -s /etc/radcli /etc/radiusclient-ng
        log_ok "Enlace simbólico de RADIUS creado."
    fi

    # Habilitar servicio
    systemctl daemon-reload
    systemctl enable asterisk
    systemctl start asterisk

    log_ok "Servicio Asterisk configurado y en ejecución."
}

# ========================== PASO 4: COMPILAR UNIMRCP CORE ====================
compile_unimrcp() {
    log_info "Paso 4: Descargando y compilando UniMRCP $UNIMRCP_VERSION..."

    cd "$SRC_DIR"

    if [[ ! -d "unimrcp-unimrcp-${UNIMRCP_VERSION}" ]]; then
        wget -q "https://github.com/unispeech/unimrcp/archive/refs/tags/unimrcp-${UNIMRCP_VERSION}.tar.gz" \
            -O "unimrcp-${UNIMRCP_VERSION}.tar.gz"
        tar -xzf "unimrcp-${UNIMRCP_VERSION}.tar.gz"
    else
        log_warn "Directorio unimrcp-unimrcp-${UNIMRCP_VERSION} ya existe."
    fi

    cd "unimrcp-unimrcp-${UNIMRCP_VERSION}"

    # Parche: eliminar llamada a apr_pool_mutex_set (no existe en APR estándar ≥1.7)
    if grep -q 'apr_pool_mutex_set' libs/apr-toolkit/src/apt_pool.c; then
        log_warn "Aplicando parche para apr_pool_mutex_set..."
        sed -i 's/apr_pool_mutex_set(pool,mutex);/\/* apr_pool_mutex_set(pool,mutex); *\//' \
            libs/apr-toolkit/src/apt_pool.c
    fi

    # Detectar la ruta del pkgconfig de Sofia-SIP
    SOFIA_PC=$(find /usr -name "sofia-sip-ua.pc" -print -quit 2>/dev/null)
    if [[ -z "$SOFIA_PC" ]]; then
        log_error "No se encontró sofia-sip-ua.pc. Instale libsofia-sip-ua-dev."
        exit 1
    fi
    log_info "Sofia-SIP detectada en: $SOFIA_PC"

    ./bootstrap
    ./configure --with-sofia-sip="$SOFIA_PC"

    NPROC=$(nproc)
    make -j"$NPROC"
    make install
    ldconfig

    log_ok "UniMRCP $UNIMRCP_VERSION instalado en /usr/local/unimrcp."
}

# ========================== PASO 5: COMPILAR MÓDULOS ASTERISK-UNIMRCP ========
compile_asterisk_unimrcp() {
    log_info "Paso 5: Descargando y compilando Asterisk-UniMRCP $ASTERISK_UNIMRCP_VERSION..."

    cd "$SRC_DIR"

    if [[ ! -d "asterisk-unimrcp-asterisk-unimrcp-${ASTERISK_UNIMRCP_VERSION}" ]]; then
        wget -q "https://github.com/unispeech/asterisk-unimrcp/archive/refs/tags/asterisk-unimrcp-${ASTERISK_UNIMRCP_VERSION}.tar.gz" \
            -O "asterisk-unimrcp-${ASTERISK_UNIMRCP_VERSION}.tar.gz"
        tar -xzf "asterisk-unimrcp-${ASTERISK_UNIMRCP_VERSION}.tar.gz"
    else
        log_warn "Directorio asterisk-unimrcp ya existe."
    fi

    cd "asterisk-unimrcp-asterisk-unimrcp-${ASTERISK_UNIMRCP_VERSION}"

    ./bootstrap
    ./configure --with-unimrcp=/usr/local/unimrcp

    NPROC=$(nproc)
    make -j"$NPROC"
    make install

    log_ok "Módulos Asterisk-UniMRCP instalados."
}

# ========================== PASO 6: CONFIGURAR UNIMRCP EN ASTERISK ===========
configure_unimrcp() {
    log_info "Paso 6: Configurando UniMRCP en Asterisk..."

    MRCP_CONF="/etc/asterisk/mrcp.conf"

    if [[ -f "$MRCP_CONF" ]]; then
        # Actualizar las IPs por defecto con la IP local de la máquina
        sed -i "s/10\.0\.0\.1/${LOCAL_IP}/g" "$MRCP_CONF"
        sed -i "s/10\.0\.0\.2/${LOCAL_IP}/g" "$MRCP_CONF"
        log_ok "mrcp.conf actualizado con IP local: $LOCAL_IP"
    else
        log_warn "No se encontró mrcp.conf. Copie manualmente desde los ejemplos."
    fi

    # Reiniciar Asterisk para cargar los nuevos módulos
    systemctl restart asterisk
    sleep 3

    log_ok "Configuración de UniMRCP completada."
}

# ========================== PASO 7: VERIFICACIÓN =============================
verify_installation() {
    log_info "Paso 7: Verificando la instalación..."

    echo ""
    log_info "Versión de Asterisk:"
    /usr/sbin/asterisk -V

    echo ""
    log_info "Módulos MRCP cargados:"
    /usr/sbin/asterisk -rx 'module show like mrcp' || true

    echo ""
    log_info "Aplicaciones MRCP registradas:"
    /usr/sbin/asterisk -rx 'core show applications like MRCP' || true

    echo ""
    log_info "Estado del servicio:"
    systemctl status asterisk --no-pager || true

    echo ""
    log_ok "=============================================="
    log_ok "  Instalación de Asterisk + UniMRCP completa  "
    log_ok "=============================================="
    echo ""
    echo "  Archivos de configuración principales:"
    echo "    - /etc/asterisk/mrcp.conf"
    echo "    - /etc/asterisk/res-speech-unimrcp.conf"
    echo "    - /etc/asterisk/pjsip.conf"
    echo "    - /etc/asterisk/extensions.conf"
    echo ""
    echo "  UniMRCP instalado en: /usr/local/unimrcp"
    echo ""
}

# ========================== EJECUCIÓN PRINCIPAL ==============================
main() {
    check_root
    detect_arch

    echo ""
    echo "=========================================================="
    echo "  Instalación de Asterisk $ASTERISK_VERSION + UniMRCP $UNIMRCP_VERSION"
    echo "  Arquitectura: $(uname -m)"
    echo "  IP local: $LOCAL_IP"
    echo "=========================================================="
    echo ""

    install_dependencies
    compile_asterisk
    configure_asterisk_service
    compile_unimrcp
    compile_asterisk_unimrcp
    configure_unimrcp
    verify_installation
}

main "$@"
