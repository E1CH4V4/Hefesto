#!/bin/bash

#     __  __           _           _        ___  
#    /__\/ _| ___  ___| |_ ___    / |      / _ \ 
#   /_\ | |_ / _ \/ __| __/ _ \   | |     | | | |
#  //__ |  _|  __/\__ \ || (_) |  | |  _  | |_| |
#  \__/ |_|  \___||___/\__\___/   |_| (_)  \___/ 
#                                                

echo "# Iniciando Hefesto 1.0"
#Distribucion de teclado
loadkeys la-latin1
echo "# Cargando distribucion de teclado..."
#Habilitar tirmpo
timedatectl set-ntp true
echo "# Cargando hora y fecha a systemctl"
#Particionar
echo "# Atencion es tiempo de paticionar el disco las particiones necesarias son \ln
    1. Particion de 512MB de tipo Efi system
    2. Particon de igual a tu cantidad de RAM si tienes,menos o igual a 8GB, para mas \ln
       de 8GB de ram solo pon 8 de tipo SWAP \ln
    3. Particion del resto del disco aqui se almacenan los datos, de tipo Linux filesystem \ln"
cfdisk
#Mostrar esquema de particiones
echo "# Esquema \ln"
lsblk
#Formatear EFI
echo "# Formateando EFI \ln"
mkfs.fat -F32 /dev/sda1
#Formateando SWAP
echo "# Formateando SWAP \ln"
mkswap /dev/sda2
swapon /dev/sda2
#Formateando Raiz
echo "# Formateando raiz \ln"
mkfs.btrfs /dev/sda3
#Montando raiz
echo "# Montando raiz"
mount /dev/sda3 /mnt
#Crear directorios de EFI
echo "# Creando directorios de EFI \ln"
mkdir /mnt/boot
mkdir /mnt/boot/efi
#Montando EFI
echo "# Montando EFI \ln"
mount /dev/sda1 /mnt/boot/efi
#Creando directorio de mirrorlist
echo "# Creando directorios de mirrorllist \ln"
mkdir /etc/pacman.d/mirrorlist
#Descargar el sistema base y el editor nano
echo "# Descargando el sistemabase y el editor nano \ln"
pacstrap /mnt base base-devel linux linux-firmware nano
genfstab -U  /mnt >> /mnt/etc/fstab
mkdir /mnt/etc/fstab
#Acceder al sistema vanilla recien instalado
echo "# Accediendo al sistema vanilla recien instalado \ln"
arch-chroot /mnt
#Pais preestablecido, cambiar postinstalacion
echo "# Pais pre establecido \ln"
ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime
#Poner el hardware ala hora
echo "# Poniendo el hardware ala hora \ln"
hwclock --systohc
#Estableciendo mapa de caracteres y idioma
echo "# Estableciendo Idioma y distribucion de teclado \ln"
echo LANG=es_MX.UTF-8 > /etc/locale.conf
echo KEYMAP=la-latin1 > /etc/vconsole.conf
#Nombre del equipo
echo "Poniendo un nombre por defecto al equipo"
echo PC > /etc/hostname
#Host preestablecido
echo "# Añadiendo host preestablecido \ln"
mv hosts /etc/
#Obteniendo administrador de red
echo "# Instalando y configurando el administrador red \ln"
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager
#Configuracion de bootloader
echo "# Instalando y configurando el bootloader \ln"
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
#Instalando el entorno grafico y gestor de acceso
echo "# Instalando entorno grafico y gestor de acceso \ln"
pacman -S gnome gdm --noconfirm
systemctl enable gdm.service
#saliendo de siatema recien instalado
echo "# Saliendo... \ln"
exit
#Desmontando 
echo "# Desmontando \ln"
unmount -R /mnt 
#Cambiando contraseña de root
echo "# Cambiar la contraseña de root, despues verificar la contraseña \ln"
passwd
#Añadiendo nuevo usoario
echo "# Añadiendo nuevo usuario predeterminado \ln"
useradd -m Predeterminado
#Cambiar contraseña a usuario predeterminado
echo "# Cambiar contraseña a usuario predeterminado, despues verificar la contraseña \ln"
passwd Predeterminado
mv sudoers /etc/
#Listo, se reiniciara
echo "# Se reiniciara la inatalacion ha terminado \ln"
echo "# Preciona enter para reiniciar \ln"
reboot