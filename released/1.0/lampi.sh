#!/bin/bash

# LICENCIA:
#
#    LAMPI Copyright © 2016 AlexDR15
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# INFORMACIÓN DEL SCRIPT
NOMBRE_INSTALADOR="LAMPI"
AUTOR_INSTALADOR="AlexDR15"
WEB_AUTOR_INSTALADOR="alexdr15.com"
VERSION_INSTALADOR="v1.0"
IDIOMA_INSTALADOR="ES"
SO_VALIDOS="Ubuntu 14.04"

# DEFINICIÓN DE VARIABLES ESENCIALES
NOMBRE_OS=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
VERSION_OS=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')
WEB_OBTENER_IP="icanhazip.com"

# MENSAJE DE BIENVENIDA
clear
echo " 
             _               __  __ ____ ______
            | |        /\   |  \/  |  __ \_   _|
            | |       /  \  | \  / | |__) || |  
            | |      / /\ \ | |\/| |  ___/ | |  
            | |____ / ____ \| |  | | |    _| |_ 
            |______/_/    \_\_|  |_|_|   |_____| $VERSION_INSTALADOR
            
		    Creado por $AUTOR_INSTALADOR
 "
echo "############################################################"
echo "#                 Bienvenido a $NOMBRE_INSTALADOR $VERSION_INSTALADOR $IDIOMA_INSTALADOR               #"
echo "############################################################"
echo ""
echo "LAMPI - An Automatic LAMP Auto Installer"
echo ""
echo "
LAMPI Copyright © 2016 AlexDR15
This program comes with ABSOLUTELY NO WARRANTY; for details type 'show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type 'show c' for details.
"
echo ""
echo "¡IMPORTANTE!: Antes de comenzar la instalación deberás responder una pregunta. Luego durante el proceso de instalación se detendrá el proceso en algunas preguntas, NO RESPONDAS! Está todo automatizado."
echo ""
echo "RECOMENDACIÓN: Pon el terminal maximizado. Así se verá todo correctamente"
echo ""
# COMPROBANDO PERMISOS
echo "¡ADVERTENCIA!: ¡Es obligatorio ejecutar este Script con permisos de root (sudo) y el instalador debe tener permisos 777 para que no de ningun error!"
if [ "$(id -u)" != "0" ]; then
   echo ""
   echo "No estás ejecutando este instalador con permisos de root"
   echo "Saliendo..."
   echo ""
   exit 1
fi

# COMPROBACIÓN DEL SISTEMA OPERATIVO
echo ""
echo "Comprobando tu versión del Sistema Operativo... (Tu versión: $NOMBRE_OS $VERSION_OS)"
echo ""
if [[ "$NOMBRE_OS" = "Ubuntu" && "$VERSION_OS" = "14.04" ]]; then 
	echo "¡Sistema Operativo Válido!"
else
	echo "¡Sistema Operativo Inválido! Válidos: $SO_VALIDOS"
	exit 1
fi

# PREGUNTAR INICIO INSTALACIÓN
function pregunta(){
echo ""
echo ""
echo "Parece que todo está correcto para comenzar el proceso de instalación, ¿quieres comenzar ahora?"
read -e -p "(S):Comenzar Ahora, (N):No Comenzar Ahora: " sino
case $sino in
	[Ss] ) ;;
    [Nn] ) echo "" && echo "" && echo "Ok, Saliendo..." && echo "" && exit;;
	* ) pregunta;;
esac
}
pregunta

# PREPARACIÓN INICIAL
clear
echo " 
                       _               __  __ ____ ______
                      | |        /\   |  \/  |  __ \_   _|
                      | |       /  \  | \  / | |__) || |  
                      | |      / /\ \ | |\/| |  ___/ | |  
                      | |____ / ____ \| |  | | |    _| |_ 
                      |______/_/    \_\_|  |_|_|   |_____| $VERSION_INSTALADOR
            
				Creado por $AUTOR_INSTALADOR
 "
echo "###########################################################"
echo "#               PREPARÁNDOSE PARA INSTALAR                #"
echo "###########################################################"
echo ""
echo "NOTA: Aparecerán los logs de instalación de los distintos paquetes."
echo ""
echo "Actualizando los repositorios y el sistema..."
apt-get -yqq update
apt-get -yqq upgrade
echo "¡Hecho!"
echo ""
echo "Instalando paquetes esenciales..."
apt-get install -yqq sudo
apt-get install -yqq makepasswd
apt-get install -yqq aptitude
aptitude -y install expect
apt-get install -yqq curl
MIIP=$(curl $WEB_OBTENER_IP)
echo "¡Hecho!"
echo ""

# PREGUNTAR PASS MYSQL ROOT
function preguntapass(){
echo ""
echo ""
echo "Antes de comenzar la instalación: Al instalar MySQL éste nos pedirá una contraseña para crear su cuenta root (Root MySQL Password)."
echo "¿Quiere asignarle la contraseña al root de MySQL o dejar una que se autogenere (contraseña segura de 16 dígitos)? "
read -e -p "Escribe la contraseña que usted desee o deje en blanco para generar una aleatoria: " PASS_MYSQL_ROOT
if [ -z "$PASS_MYSQL_ROOT" ]; then
	PASS_MYSQL_ROOT=$(makepasswd --chars=16)
fi
}
preguntapass

echo ""
echo "Contraseña definida para Root MYSQL (Esta contraseña se guardará luego en un archivo con el resto de credenciales): $PASS_MYSQL_ROOT"
echo ""

read -p "Pulsa Enter (Intro) para comenzar la instalación..."

# DEFINE NUEVAS CONTRASEÑAS
PASS_PHPMYADMIN_ROOT=$(makepasswd --chars=16)

# INSTALACIÓN APACHE2
clear
echo " 
                       _               __  __ ____ ______
                      | |        /\   |  \/  |  __ \_   _|
                      | |       /  \  | \  / | |__) || |  
                      | |      / /\ \ | |\/| |  ___/ | |  
                      | |____ / ____ \| |  | | |    _| |_ 
                      |______/_/    \_\_|  |_|_|   |_____| $VERSION_INSTALADOR
            
				Creado por $AUTOR_INSTALADOR
 "
echo "############################################################"
echo "#                  INSTALACIÓN EN MARCHA                   #"
echo "############################################################"
echo ""
echo "Instalando Apache2..."
sudo apt-get -y install apache2
echo "¡Hecho!"
echo ""

# INSTALACIÓN MYSQL
echo "Instalando MySQL..."
echo "mysql-server mysql-server/root_password password $PASS_MYSQL_ROOT" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $PASS_MYSQL_ROOT" | debconf-set-selections
sudo apt-get -y install mysql-server libapache2-mod-auth-mysql
echo "¡Hecho!"
echo ""

# CONFIGURACIÓN MYSQL
echo "Configurando y Asegurando MySQL..."
# DEFINICIÓN INTALACIÓN SEGURA MYSQL
/usr/bin/expect <<EOD
spawn mysql_secure_installation

expect "Enter current password for root (enter for none):"
send "$PASS_MYSQL_ROOT\r"
	
expect "Change the root password?"
send "y\r"

expect "New password:"
send "$PASS_MYSQL_ROOT\r"

expect "Re-enter new password:"
send "$PASS_MYSQL_ROOT\r"

expect "Remove anonymous users?"
send "y\r"

expect "Disallow root login remotely?"
send "y\r"

expect "Remove test database and access to it?"
send "y\r"

expect "Reload privilege tables now?"
send "y\r"

puts "Finalizada configuracion desde expect."
EOD
# EJECUCIÓN INSTALACIÓN SEGURA MYSQL
echo "${SECURE_MYSQL}"
echo "¡Hecho!"
echo ""

# INSTALACIÓN PHP Y COMPLEMENTOS
echo "Instalando php y sus módulos esenciales..."
sudo apt-get -yqq install php5 php-pear php5-mysql php5-curl php5-gd php5-mcrypt
echo "¡Hecho!"
echo ""

# INSTALACIÓN PHPMYADMIN
echo "Instalando, Configurando y Protegiendo phpMyAdmin..."
# DEFINICIÓN DEBCONF-SELECTIONS
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PASS_MYSQL_ROOT" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PASS_PHPMYADMIN_ROOT" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PASS_PHPMYADMIN_ROOT" | debconf-set-selections
# EJECUCIÓN INSTALACIÓN
apt-get -y install phpmyadmin
# SECURIZACIÓN
echo ""
echo ""
echo "Securizando phpMyAdmin..."
echo ""
echo "¿Qué enlace te gustaría usar para acceder a phpMyAdmin? (Deja en Blanco para el default 'phpmyadmin'):"
read -e -p "Enlace: http://$MIIP/" PHPMYADMIN_DIR
if [ -z "$PHPMYADMIN_DIR" ]; then
	PHPMYADMIN_DIR="phpmyadmin"
fi
sed -i -r "s:(Alias /).*(/usr/share/phpmyadmin):\1$PHPMYADMIN_DIR \2:" /etc/phpmyadmin/apache.conf
php5enmod mcrypt
service apache2 reload
echo ""
echo "¡Hecho!"

# FINAL
clear
echo " 
                       _               __  __ ____ ______
                      | |        /\   |  \/  |  __ \_   _|
                      | |       /  \  | \  / | |__) || |  
                      | |      / /\ \ | |\/| |  ___/ | |  
                      | |____ / ____ \| |  | | |    _| |_ 
                      |______/_/    \_\_|  |_|_|   |_____| $VERSION_INSTALADOR
            
				Creado por $AUTOR_INSTALADOR
 "
echo "############################################################"
echo "#           ¡INSTALACIÓN COMPLETADA CON ÉXITO!             #"
echo "############################################################"
echo ""
echo "ATENCIÓN: Guarda las credenciales que aparecerán abajo. También encontrarás guardadas las credenciales en el directorio del instalador en un archivo llamado 'credenciales_lampi.txt'"
echo ""

# GUARDADO EN EL ARCHIVO
echo " 
                       _               __  __ ____ ______
                      | |        /\   |  \/  |  __ \_   _|
                      | |       /  \  | \  / | |__) || |  
                      | |      / /\ \ | |\/| |  ___/ | |  
                      | |____ / ____ \| |  | | |    _| |_ 
                      |______/_/    \_\_|  |_|_|   |_____| $VERSION_INSTALADOR
            
				Creado por $AUTOR_INSTALADOR
 " >> credenciales_lampi.txt
echo "############################################################" >> credenciales_lampi.txt
echo "#                    $NOMBRE_INSTALADOR - Credenciales                  #" >> credenciales_lampi.txt
echo "############################################################" >> credenciales_lampi.txt
echo "Root MySQL: $PASS_MYSQL_ROOT" >> credenciales_lampi.txt
echo "Contraseña de Aplicación y Base de Datos phpMyAdmin: $PASS_PHPMYADMIN_ROOT" >> credenciales_lampi.txt
echo "Para acceder al phpMyAdmin: http://$MIIP/$PHPMYADMIN_DIR" >> credenciales_lampi.txt
echo "" >> credenciales_lampi.txt
echo "  --  Credenciales Utilizadas para los servicios LAMP por $NOMBRE_INSTALADOR  --  " >> credenciales_lampi.txt

echo "$NOMBRE_INSTALADOR - Credenciales:"
echo "Root MySQL: $PASS_MYSQL_ROOT"
echo "Contraseña de Aplicación y Base de Datos phpMyAdmin: $PASS_PHPMYADMIN_ROOT"
echo "Para acceder al phpMyAdmin: http://$MIIP/$PHPMYADMIN_DIR"

# PREGUNTAR FINAL INSTALACIÓN
function eliminarpregunta(){
echo ""
echo ""
echo "¡IMPORTANTE! Para el proceso de instalación se han utilizado 3 programas adicionales: 'makepasswd' (Generador de Contraseñas), 'expect' (Interactua en la ejecución de scripts), 'curl' (Obtiene resultado de una consulta web (Se recomienda dejarlo instalado))."
echo "Éstos ya no serán necesarios para el funcionamiento de LAMP."
echo "¿Quieres eliminarlos ahora?"
read -e -p "Escribe 1 letra: (T):Eliminar los 3, (M):Eliminar solo 'makepasswd', (E):Eliminar solo 'expect', (C):Eliminar solo 'curl', (N):No eliminar ninguno: " eliminacion
case $eliminacion in
	[Tt] ) echo "" && echo "" && echo "Eliminando ámbos programas..." && apt-get purge -yqq makepasswd && aptitude -y purge expect && apt-get purge -yqq curl && echo "" && echo "¡Hecho!" && finaltotal;;
    [Mm] ) echo "" && echo "" && echo "Eliminando solo 'makepasswd'..." && apt-get purge -yqq makepasswd && echo "" && echo "¡Hecho!" && eliminarpregunta2;;
    [Ee] ) echo "" && echo "" && echo "Eliminando solo 'expect'..." && aptitude -y purge expect && echo "" && echo "¡Hecho!" && eliminarpregunta2;;
    [Cc] ) echo "" && echo "" && echo "Eliminando solo 'curl'..." && apt-get purge -yqq curl && echo "" && echo "¡Hecho!" && eliminarpregunta2;;
    [Nn] ) echo "" && echo "" && echo "No se eliminará ningún programa..." && finaltotal;;
	* ) eliminarpregunta;;
esac
}
function eliminarpregunta2(){ 
echo "" 
echo "" 
read -e -p "¿Quieres eliminar otro más? [S/N]" pregunta3 
case $pregunta3 in 
	[Ss] ) eliminarpregunta;;
	[Nn] ) finaltotal;;
	* ) eliminarpregunta2;;
esac
}
function finaltotal(){
echo ""
echo "¡Muchas Gracias por usar $NOMBRE_INSTALADOR!"
echo ""
}
eliminarpregunta
exit 0

# LAMPI Copyright © 2016 AlexDR15