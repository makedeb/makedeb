set -x
# INSTALL NEEDED PACKAGES
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get dist-upgrade -y
apt-get install wget sudo -y
# SET UP REPO AND INSTALL CURRENT COPY OF MAKEDEB
wget 'https://hunterwittenborn.com/keys/apt.asc' -O /etc/apt/trusted.gpg.d/hwittenborn.asc
echo 'deb [arch=all] https://repo.hunterwittenborn.com/debian/makedeb any main' | tee /etc/apt/sources.list.d/makedeb.list
apt-get update
apt-get install makedeb -y
# CREATE BUILD USER
useradd -m user
# SET FOLDER PERMS AND BUILD MAKEDEB
chown user:user /drone/
chown user:user /drone/src -R
sudo -u user ./makedeb.sh
