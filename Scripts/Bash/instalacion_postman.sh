#!/bin/bash

# 1. Descargar la última versión de Postman
echo "Descargando Postman..."
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz

# 2. Extraer el archivo en /opt
echo "Extrayendo en /opt..."
sudo tar -xzf postman.tar.gz -C /opt
rm postman.tar.gz

# 3. Crear un enlace simbólico para ejecutarlo desde la terminal
echo "Creando acceso directo en el sistema..."
sudo ln -sf /opt/Postman/Postman /usr/bin/postman

# 4. Crear el archivo de escritorio para KDE Plasma 6.5
echo "Configurando acceso en el menú de aplicaciones..."
cat <<EOF >postman.desktop
[Desktop Entry]
Name=Postman
GenericName=API Client
Comment=Design, develop, and test your APIs
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
StartupWMClass=Postman
EOF

# 5. Mover el archivo .desktop a la carpeta de aplicaciones del sistema
sudo mv postman.desktop /usr/share/applications/

echo "----------------------------------------------------"
echo "¡Instalación completada con éxito!"
echo "Ya puedes buscar 'Postman' en tu lanzador de KDE Plasma."
echo "----------------------------------------------------"
