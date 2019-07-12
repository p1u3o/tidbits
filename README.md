# Silverblue tidbits
Some things I do on Fedora Silverblue (best Linux desktop btw) to get software I want on the host whilst trying to avoid package overlaying. This is entirely for myself, but maybe others might find it useful.

- Contents
	- [Google Chrome](#google-chrome)
  - [Nano](#nano)
  - [Android Tools (adb, fastboot etc)](#android-tools-adb-fastboot-etc)
  - [MS Core Fonts](#ms-core-fonts) Arial, Courier, Times, Webdings etc
  - [youtube-dl](#youtube-dl)
  - [wireguard](#wireguard)
  - [Broadcom Wireless Driver (wl)](#broadcom)
  - [NVIDIA](#nvidia)

### Google Chrome
It's a bad idea to install the Google Chrome RPM, you'll eventually get stuck in an update loop where the rpm keeps replacing the update each time.

#### Repo

```bash
sudo -i
```
```bash
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
```

#### Install

```bash
rpm-ostree install google-chrome-stable
```
---

### Nano

#### ncurses

```bash
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz
tar -xvf ncurses-6.1.tar.gz && cd ncurses-6.1
./configure --prefix=/usr/local
make -j4
sudo make install
```

#### nano
```bash
wget https://www.nano-editor.org/dist/v4/nano-4.3.tar.gz
tar -xvf nano-4.3.tar.gz && cd nano-4.3
CFLAGS="-I/usr/local/include/ncurses" ./configure --prefix=/usr/local
make -j4
sudo make install
```
---

### Android Tools (adb, fastboot etc)

```bash
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
sudo cp -v platform-tools/adb platform-tools/fastboot platform-tools/mke2fs* platform-tools/e2fsdroid /usr/local/bin
```

#### Device rules (to use without root)

```bash
git clone https://github.com/M0Rf30/android-udev-rules.git
cd android-udev-rules
sudo cp -v 51-android.rules /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo groupadd adbusers
sudo usermod -a -G adbusers $(whoami)
sudo systemctl restart systemd-udevd.service
adb kill-server
adb devices
```
---

### MS Core Fonts

#### cabextract
```bash
wget https://www.cabextract.org.uk/cabextract-1.9.1.tar.gz
tar -xvf cabextract-1.9.1.tar.gz
cd cabextract-1.9.1
./configure --prefix=/usr/local && make
sudo make install
```

#### mscorefonts.sh

```bash
wget https://raw.githubusercontent.com/p1u3o/tidbits/master/mscorefonts.sh
sh mscorefonts.sh
```
##### To install user-wide (Flatpak will see these)
```bash
mkdir ~/.local/share/fonts
mkdir ~/.local/share/fonts/mscorefonts
cp -v fonts/*.ttf fonts/*.TTF ~/.local/share/fonts/mscorefonts/
```
##### To install system-wide (Flatpak might not see these yet)
```bash
sudo mkdir /usr/local/share/fonts/
sudo mkdir /usr/local/share/fonts/mscorefonts/
sudo cp -v fonts/*.ttf fonts/*.TTF /usr/local/share/fonts/mscorefonts/
```
---

### youtube-dl

#### Python Fix
```bash
sudo ln -s /usr/bin/python3 /usr/local/bin/python
```
#### youtube-dl
```bash
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
youtube-dl
```
---

### wireguard

#### rpm fusion

Enable RPM Fusion if you haven't already

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Reboot

#### kmod

```bash
rpm-ostree install akmod-wireguard
```
Reboot

---

### Broadcom

#### rpm fusion

Enable RPM Fusion if you haven't already

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Reboot

#### kmod

```bash
rpm-ostree install akmod-wl
```
Reboot

---

### NVIDIA

#### rpm fusion

Enable RPM Fusion if you haven't already

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Reboot

#### kmod & drivers

```bash
rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
```

#### initramfs

If you want to make sure the nvidia driver is part of the initramfs, which allows the modesetting driver to work sooner (full screen boot logo), enable initramfs generation. I personally recommend this, although it comes at the cost of slower updates.

```bash
rpm-ostree initramfs --enable
```

Reboot
