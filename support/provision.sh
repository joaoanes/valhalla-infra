#!/bin/bash
# thank you https://github.com/Nimdy/Dedicated_Valheim_Server_Script
set -euxo pipefail

# thank you https://gist.github.com/tedivm/e11ebfdc25dc1d7935a3d5640a1f1c90
# wait for first boot apt background installs
apt_wait() {
  while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
    sleep 1
  done
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    sleep 1
  done
  while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    sleep 1
  done
  if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
    while sudo fuser /var/log/unattended-upgrades/unattended-upgrades.log >/dev/null 2>&1; do
      sleep 1
    done
  fi
}

dpkg --add-architecture i386
apt_wait

apt update
apt_wait

echo "steam steam/question note I AGREE" | sudo debconf-set-selections
apt_wait

echo "steam steam/license note ''" | sudo debconf-set-selections
apt_wait

# we need both i386 and regular libs since the valheim server binaries
# are on the default architecture, and it also benefits from a speed boost with sdl installed
apt install steamcmd:i386 libsdl2-2.0-0:i386 libsdl2-2.0-0 -y
# shellcheck disable=SC2154
# shellcheck disable=SC2086
{
  useradd --create-home --shell /bin/bash --password ${steam_user_password} steam
}
cp /etc/skel/.bashrc /home/steam/.bashrc
cp /etc/skel/.profile /home/steam/.profile

/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/valheimserver \
  +app_update 896660 validate +exit

mv /home/ubuntu/run.sh /home/steam/valheimserver/run.sh
chmod +x /home/steam/valheimserver/run.sh
chown steam:steam -Rf /home/steam/*

mv /home/ubuntu/valhalla.service /etc/systemd/system

# shellcheck disable=SC2154
# shellcheck disable=SC2086
{
  wget https://s3.${aws_region}.amazonaws.com/${route53_subdomain}-backups-next/valheim.tar.gz
}

sudo tar -xvzf /home/ubuntu/valheim.tar.gz --directory /

chmod +x /home/ubuntu/backup.sh
crontab /home/ubuntu/crontab

systemctl daemon-reload
systemctl start valhalla
systemctl enable valhalla
