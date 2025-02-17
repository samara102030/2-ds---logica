#!/bin/bash

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

# Export do proxy em Solucao por agora sendo tosca e 'cinica': via teste dns prd
# se der ping no prdpac.prd eh prdproxy nele dai

ping -c1 -w1 prdpac.prd  >> /dev/null 2>&1
if [ $? -eq 0 ]; then
   cd /tmp
   wget -q prdpac.prd/proxy.pac
   if [ $? -eq 0 ]; then
      echo "Rede com proxy PRD  $(date +%d_%m_%Y_%H_%M_%S_%N)" >> /tmp/.volumeloginstall.txt
      PROXY="prdproxy.prd"
      PORTA="8080"
      export http_proxy="http://${PROXY}:${PORTA}"
      export https_proxy="http://${PROXY}:${PORTA}"
      export ftp_proxy="http://${PROXY}:${PORTA}"
   else
      if [ ! -e "/usr/bin/x11vnc" ]; then
         echo "Rede estranha, tentando sem proxy"
      fi
   fi
else
   echo "Rede particular, NRE ou SEED ou pode estar sem rede nenhuma $(date +%d_%m_%Y_%H_%M_%S_%N)" >> /tmp/.volumeloginstall.txt
   ping -c1 -w1 proxy.educacao.parana >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      echo "Definindo proxy rede NREs/SEED $(date +%d_%m_%Y_%H_%M_%S_%N)" >> /tmp/.volumeloginstall.txt
      PROXY="10.74.32.2"
      PORTA="3128"
      export http_proxy="http://${PROXY}:${PORTA}"
      export https_proxy="http://${PROXY}:${PORTA}"
      export ftp_proxy="http://${PROXY}:${PORTA}"
   else
      echo "Nem rede PRD, SEED ou NRE detectada $(date +%d_%m_%Y_%H_%M_%S_%N)" >> /tmp/.volumeloginstall.txt
   fi
fi

cat > "/etc/xdg/autostart/volume150.desktop" << EndOfThisFileIsExactHereNowReally
[Desktop Entry]
Version=1.0
Type=Application
Name=VolumeEm150
Comment=VolumeEm150
Exec=/usr/bin/pactl set-sink-volume 0 150%
Icon=preferences-system-sound
Path=
Terminal=true
StartupNotify=false
EndOfThisFileIsExactHereNowReally
chmod +x /etc/xdg/autostart/volume150.desktop

echo "ativado volume 150 ao fazer login: ok "
echo -e "\e[1;34m Por favor sair do login e entrar novamente pra testar se fez 150%!\e[0m"
