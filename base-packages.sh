#!/bin/bash

##########################################################
#                                                        #
#             SMD-Linux Installation Script              #
#       Base Install Script for UEFI Installation        #
#                                                        #
#  Run after Chroot into new system (# arch-chroot /mnt) #
#                                                        #
##########################################################
#                                                        #
######################## Variables #######################
#
# b=bold u=underline bl=black r=red g=green
# y=yellow bu=blue m=magenta c=cyan w=white
# endc=end-color enda=end-argument
b='\033[1m'
u='\033[4m'
bl='\E[30m'
r='\E[31m'
g='\E[32m'
y='\E[33m'
bu='\E[34m'
m='\E[35m'
c='\E[36m'
w='\E[37m'
endc='\E[0m'
enda='\033[0m'
version="20230125"
####################### Functions ########################

function install {
  # Check If Package Is Installed
  if pacman -Qi $1 &> /dev/null; then
      echo -e " [${g}✔${endc}]::[${b}"$1"${enda}] Is Already Installed!"
  else
      pacman -S --noconfirm --needed $1
      # Verify Successful Installation
    if pacman -Qi $package &> /dev/null; then
      echo -e " [${g}✔${endc}]::[${b}"$1"${enda}]: Installed!"
    else
      echo -e " [${r}!${endc}]::[${b}"$1"${enda}]: ${r}NOT Installed!${endc}"
    fi
  fi
}

function category {
	echo -e " [${g}✔${endc}]::Installing Software For Category ${b}${bu}["$1"]${endc}${enda}"
	echo
}

function end_category {
	echo
    echo -e " [${g}✔${endc}]::Category ${bu}${b}["$1"]${enda}${endc} Installed!"
    echo
}
##########################################################

echo
echo -e " [${g}✔${endc}]::[${g}${b}Set Time Zone${enda}${endc}]"
echo

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

echo
echo -e " [${g}✔${endc}]::[${g}${b}Localization${enda}${endc}]"
echo

sed -i '178s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo
echo -e " [${g}✔${endc}]::[${g}${b}Network Configuration${enda}${endc}]"
echo

echo "archlinux-pc" >> /etc/hostname

echo '
127.0.0.1     localhost
::1           localhost
127.0.1.1     archlinux-pc.loaldomain  archlinux-pc
' | tee --append /etc/hosts

echo
echo -e " [${g}✔${endc}]::[${g}${b}Set Root Password${enda}${endc}]"
echo

echo root:password | chpasswd

###############################################################################

category ArchLinux-Base-Packages

list=(
grub
efibootmgr
networkmanager
network-manager-applet
dialog
wpa_supplicant
mtools
dosfstools
base-devel
linux-headers
xdg-user-dirs
xdg-utils
inetutils
dnsutils
alsa-utils
pipewire
pipewire-alsa
pipewire-pulse
pipewire-jack
bash-completion
openssh
rsync
reflector
openbsd-netcat
os-prober
ntfs-3g
terminus-font
pulseaudio
xf86-video-amdgpu
)

count=0

for name in "${list[@]}" ; do
  count=$[count+1]
  echo -e " ${y}Installing package # "$count" ${b}["$name"]${enda} ${endc}" ;
  install $name
done

###############################################################################

end_category ArchLinux-Base-Packages


###############################################################################

echo
echo -e " [${g}✔${endc}]::[${g}${b}Install and Configure Grub${enda}${endc}]"
echo

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable reflector.timer
systemctl enable fstrim.timer

echo
echo -e " [${g}✔${endc}]::[${g}${b}Add User${enda}${endc}]"
echo

useradd -m seth
echo seth:password | chpasswd

echo "seth ALL=(ALL) ALL" >> /etc/sudoers.d/seth

echo
echo -e " [${g}✔${endc}]::[${g}${b}Done, Type exit, umount -a and reboot${enda}${endc}]"
echo
